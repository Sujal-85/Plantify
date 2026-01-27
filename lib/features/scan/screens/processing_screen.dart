import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:plant_analysis/core/utils/platform_utils.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';
import 'package:plant_analysis/features/results/screens/results_screen.dart';
import 'package:plant_analysis/core/services/tflite_service.dart';
import 'package:plant_analysis/core/services/database_service.dart';
import 'package:plant_analysis/core/services/sync_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  void _updateStatus(String status) {
    if (!mounted) return;
    debugPrint("STATUS → $status");
    setState(() => _statusText = status);
  }

  Future<void> _processImage() async {
    final tfliteService = context.read<TFLiteService>();
    final dbService = context.read<DatabaseService>();
    final syncService = context.read<SyncService>();

    String label = 'Unknown';
    double confidence = 0.0;
    
    // YIELD TO UI: Give the navigation animation time to finish and the first frame to paint.
    // Also gives the Isolate a split second to finish handshake if it was just spawned.
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if model is ready to give accurate status
    if (!tfliteService.isModelLoaded) {
       _updateStatus("Warming up AI Engine...");
    } else {
       _updateStatus("Analyzing Image...");
    }

    try {
      /// 🔥 SAFE TFLITE CALL (NON-BLOCKING)
      // The Service now runs in a separate Isolate, so this await 
      // is truly waiting for a message, not blocking the UI thread.
      final rawResult = await tfliteService.predict(widget.imagePath);

      if (rawResult == null || rawResult is! Map) {
        throw Exception("Invalid prediction output");
      }

      debugPrint("TFLite RESULT → $rawResult");

      /// ✅ SAFE PARSING
      label = rawResult['label']?.toString() ?? 'Unknown';
      label = label.replaceAll('___', ' ').replaceAll('_', ' ');

      final rawConfidence = rawResult['confidence'];
      if (rawConfidence is num) {
        confidence = rawConfidence.toDouble();
      }

      if (label == 'Timeout' || label == 'Detection Failed') {
        throw Exception("AI analysis failed");
      }

      _updateStatus("Saving Result...");

      /// 🔁 BACKGROUND SAVE (NON BLOCKING)
      dbService
          .saveScan(widget.imagePath, label, confidence)
          .then((_) => syncService.triggerSync())
          .catchError((e) {
        debugPrint("DB SAVE ERROR (ignored): $e");
      });

      if (!context.mounted) return;

      _updateStatus("Done!");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            imagePath: widget.imagePath,
            label: label,
            confidence: confidence,
          ),
        ),
      );
    } catch (e) {
      debugPrint("PROCESSING ERROR → $e");
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Diagnosis failed: $message"),
        backgroundColor: Colors.red,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned.fill(
            child: displayImage(
              widget.imagePath,
              color: Colors.black.withValues(alpha: 0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: const Icon(
                      Icons.search,
                      size: 60,
                      color: Colors.white,
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          duration: 1000.ms,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(1, 1),
                          duration: 1000.ms,
                        ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2000.ms, color: AppColors.accent),

                const SizedBox(height: 30),

                Text(
                  _statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 10),

                const Text(
                  'Identifying disease patterns',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
