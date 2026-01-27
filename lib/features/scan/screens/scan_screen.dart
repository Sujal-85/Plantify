
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import 'processing_screen.dart';
import '../../identify/screens/identify_processing_screen.dart';
import 'package:provider/provider.dart';
import 'package:plant_analysis/core/services/tflite_service.dart';

class ScanScreen extends StatefulWidget {
  final bool isIdentifyMode;
  const ScanScreen({super.key, this.isIdentifyMode = true});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isDiagnosing = false;
  double _progress = 0.0;
  late bool _isIdentifyMode;

  @override
  void initState() {
    super.initState();
    _isIdentifyMode = widget.isIdentifyMode;
    // 🚀 PRE-LOAD MODEL: Start the heavy isolate spawn NOW while user frames the shot
    // This removes the delay from the ProcessingScreen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TFLiteService>().loadModel();
    });
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.low, // Lowest resolution for maximum stability
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CameraPreview(_controller!),
          ),

          // Top Bar
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  _isIdentifyMode ? 'Identifying Plants' : 'Diagnose',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Scanning Frame (Green)
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Corner markers (Thickened)
                  ..._buildCorners(),
                  
                  // Particle Effects (Floating dots for identification)
                  if (_isIdentifyMode && !_isDiagnosing)
                  ...List.generate(6, (index) => _buildParticle(index)),
                  
                  // Scanning Beam Animation
                  if (!_isIdentifyMode && !_isDiagnosing)
                  Container(
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 4, spreadRadius: 2)
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .slideY(begin: 0, end: 150, duration: 2000.ms),
                ],
              ),
            ),
          ),

          // Progress Bar (when diagnosing/identifying)
          if (_isDiagnosing)
          Positioned(
            bottom: 220,
            left: 60,
            right: 60,
            child: Column(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isIdentifyMode ? 'Identifying plants...' : 'Diagnosing plants...',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _modeToggle('Identify', _isIdentifyMode, () => setState(() => _isIdentifyMode = true)),
                    const SizedBox(width: 20),
                    _modeToggle('Diagnose', !_isIdentifyMode, () => setState(() => _isIdentifyMode = false)),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircularButton(Icons.folder_outlined, () {}),
                    GestureDetector(
                      onTap: _isDiagnosing ? null : _startProcess,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    _buildCircularButton(Icons.image_outlined, _pickFromGallery),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeToggle(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final positions = [
      Offset(40, 60), Offset(220, 80), Offset(140, 160),
      Offset(60, 240), Offset(200, 220), Offset(130, 40)
    ];
    final position = positions[index % positions.length];
    
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
       .fadeOut(duration: (1000 + index * 200).ms, delay: (index * 100).ms)
       .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5), duration: (1000 + index * 200).ms),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildCorners() {
    return [
      Positioned(top: 0, left: 0, child: _corner(0)),
      Positioned(top: 0, right: 0, child: RotatedBox(quarterTurns: 1, child: _corner(0))),
      Positioned(bottom: 0, left: 0, child: RotatedBox(quarterTurns: 3, child: _corner(0))),
      Positioned(bottom: 0, right: 0, child: RotatedBox(quarterTurns: 2, child: _corner(0))),
    ];
  }

  Widget _corner(double angle) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 6),
          left: BorderSide(color: AppColors.primary, width: 6),
        ),
      ),
    );
  }

  Future<void> _startProcess() async {
    debugPrint("ScanScreen: _startProcess called");
    // 1. Animate scanning immediately
    setState(() {
      _isDiagnosing = true;
      _progress = 0.5; // Show some progress immediately
    });
    
    // 2. Take Picture (Real) - No fake delays
    debugPrint("ScanScreen: About to take picture immediately");
    await _takePicture();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
       debugPrint("ScanScreen: Camera not initialized");
       return;
    }

    try {
      debugPrint("ScanScreen: Taking picture...");
      final image = await _controller!.takePicture();
      debugPrint("ScanScreen: Picture taken at ${image.path}");
      
      if (!mounted) {
         debugPrint("ScanScreen: Not mounted after capture");
         return;
      }

      // Navigate to appropriate processing screen
      debugPrint("ScanScreen: Navigating to processing screen (Identify: $_isIdentifyMode)");
      if (_isIdentifyMode) {
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => IdentifyProcessingScreen(imagePath: image.path),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProcessingScreen(imagePath: image.path),
          ),
        ).then((_) => debugPrint("ScanScreen: Navigation completed/returned"));
      }
    } catch (e) {
      debugPrint("Error taking picture or navigating: $e");
      setState(() => _isDiagnosing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera Error: Failed to capture image. Please try Gallery.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open Gallery',
              textColor: Colors.white,
              onPressed: _pickFromGallery,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    debugPrint("ScanScreen: Picking from gallery...");
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        debugPrint("ScanScreen: Image picked from gallery: ${image.path}");
        if (mounted) {
          debugPrint("ScanScreen: Navigating to ProcessingScreen...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProcessingScreen(imagePath: image.path),
            ),
          );
        }
      } else {
        debugPrint("ScanScreen: Gallery picker cancelled/failed");
      }
    } catch (e) {
      debugPrint("ScanScreen: Error picking from gallery: $e");
    }
  }
}
