import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  // Isolate communication
  Isolate? _isolate;
  SendPort? _sendPort;
  final Completer<void> _initCompleter = Completer<void>();
  
  // Pending requests map to match responses to calls
  final Map<int, Completer<Map<String, dynamic>>> _pendingRequests = {};
  int _requestIdCounter = 0;

  bool _isModelLoaded = false;
  Future<void>? _loadingFuture;
  bool get isModelLoaded => _isModelLoaded && _sendPort != null;

  /// Loads the model and spawns the background isolate.
  /// Must be called once before predicting.
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    if (_loadingFuture != null) return _loadingFuture;

    _loadingFuture = _loadModelInternal();
    return _loadingFuture;
  }

  Future<void> _loadModelInternal() async {
    try {
      debugPrint("TFLiteService: Loading assets on Main Thread...");
      
      // 1. Load Assets on Main Thread (Safe)
      final modelData = await rootBundle.load('assets/ml/model.tflite');
      final modelBuffer = modelData.buffer.asUint8List();

      final labelData = await rootBundle.loadString('assets/ml/labels.txt');
      final labels = labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (labels.isEmpty) throw Exception("No labels found");

      debugPrint("TFLiteService: Assets loaded. Spawning Isolate...");

      // 2. Spawn Isolate
      final receivePort = ReceivePort();
      _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
      
      // 3. Setup Listener
      receivePort.listen(_handleIsolateMessage);

      // 4. Send Init Command
      // We wait for the first message from the isolate which is the SendPort
      // but here we used specific protocol: Isolate sends SendPort first.
      
      _isModelLoaded = true;
      
      // We need to send the model to the isolate. 
      // The listener loop below will handle the handshake.
      
      // Wait for handshake handled in listener
      // We actually need a way to send the init data *after* getting the port.
      // So we'll store the init data and send it when _sendPort is assigned.
      
      _pendingInitData = {
        'model': modelBuffer,
        'labels': labels,
      };

    } catch (e) {
      debugPrint("TFLiteService: Error loading model: $e");
      _isModelLoaded = false;
      if (!_initCompleter.isCompleted) _initCompleter.completeError(e);
    }
  }

  Map<String, dynamic>? _pendingInitData;

  void _handleIsolateMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      debugPrint("TFLiteService: Handshake received. Sending Model...");
      
      if (_pendingInitData != null) {
        _sendPort!.send({
          'type': 'init',
          'model': _pendingInitData!['model'],
          'labels': _pendingInitData!['labels'],
        });
        _pendingInitData = null;
      }
    } else if (message is Map) {
      final type = message['type'];
      
      if (type == 'init_success') {
        debugPrint("TFLiteService: Isolate initialized successfully.");
        if (!_initCompleter.isCompleted) _initCompleter.complete();
      } else if (type == 'error') {
        final reqId = message['id'];
        final error = message['error'];
        debugPrint("TFLiteService: Received Error: $error");
        
        if (reqId != null && _pendingRequests.containsKey(reqId)) {
          _pendingRequests.remove(reqId)!.completeError(error);
        }
      } else if (type == 'result') {
        final reqId = message['id'];
        if (reqId != null && _pendingRequests.containsKey(reqId)) {
          _pendingRequests.remove(reqId)!.complete({
            'label': message['label'],
            'confidence': message['confidence'],
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>> predict(String imagePath) async {
    if (!_isModelLoaded) {
       debugPrint("TFLiteService: Auto-initializing model...");
       loadModel();
    }
    
    if (_sendPort == null) {
      debugPrint("TFLiteService: Model not ready. Waiting...");
      await _initCompleter.future; // Wait for init
    }

    final id = _requestIdCounter++;
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[id] = completer;

    _sendPort!.send({
      'type': 'predict',
      'id': id,
      'imagePath': imagePath,
    });

    return completer.future.timeout(
      const Duration(seconds: 15), 
      onTimeout: () {
        _pendingRequests.remove(id);
        throw TimeoutException("TFLite Inference Timed Out");
      },
    );
  }

  void close() {
    _sendPort?.send({'type': 'close'});
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
  }
}

// --- BACKGROUND ISOLATE CODE ---

void _isolateEntry(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort); // Handshake

  Interpreter? interpreter;
  List<String> labels = [];

  receivePort.listen((message) async {
    if (message is Map) {
      final type = message['type'];

      if (type == 'init') {
        try {
          final Uint8List modelBuffer = message['model'];
          labels = List<String>.from(message['labels']);
          
          final options = InterpreterOptions();
          interpreter = Interpreter.fromBuffer(modelBuffer, options: options);
          
          sendPort.send({'type': 'init_success'});
        } catch (e) {
          sendPort.send({'type': 'error', 'error': 'Init failed: $e'});
        }
      } else if (type == 'predict') {
        final id = message['id'];
        final String path = message['imagePath'];

        try {
          if (interpreter == null) throw Exception("Interpreter not initialized");

          // 1. Preprocess
          final imageFile = File(path);
          if (!imageFile.existsSync()) throw Exception("File not found");

          final imageBytes = imageFile.readAsBytesSync();
          final image = img.decodeImage(imageBytes);
          if (image == null) throw Exception("Failed to decode image");

          final resized = img.copyResize(image, width: 224, height: 224);

          // Convert to Float32 [1, 224, 224, 3]
          // Using a flat Float32List is faster for TFLite if input tensor expects it,
          // but we will stick to the nested list structure if that's what the model expects,
          // OR better: use a flattened buffer if the model supports it.
          // Most tflite_flutter examples use: List<Object> inputs = [input];
          // where input is [1, 224, 224, 3].
          
          var input = List.generate(
            1,
            (i) => List.generate(
              224,
              (y) => List.generate(224, (x) {
                final pixel = resized.getPixel(x, y);
                return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
              }),
            ),
          );

          // 2. Inference
          final outputBuffer = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);
          interpreter!.run(input, outputBuffer);

          // 3. Postprocess
          final probs = outputBuffer[0] as List<dynamic>;
          double maxProb = -1.0;
          int maxIndex = -1;

          for (int i = 0; i < probs.length; i++) {
            if (probs[i] > maxProb) {
              maxProb = probs[i];
              maxIndex = i;
            }
          }

          final label = (maxIndex != -1 && maxIndex < labels.length) 
              ? labels[maxIndex] 
              : 'Unknown';

          sendPort.send({
            'type': 'result',
            'id': id,
            'label': label,
            'confidence': maxProb,
          });

        } catch (e) {
          sendPort.send({
            'type': 'error', 
            'id': id, 
            'error': e.toString()
          });
        }
      } else if (type == 'close') {
        interpreter?.close();
        Isolate.current.kill();
      }
    }
  });
}
