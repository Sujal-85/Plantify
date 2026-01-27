import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/scanner_overlay.dart';
// I'll create scanner_overlay.dart next

class PlantIdScreen extends StatefulWidget {
  const PlantIdScreen({super.key});

  @override
  State<PlantIdScreen> createState() => _PlantIdScreenState();
}

class _PlantIdScreenState extends State<PlantIdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // If pushed from Home, pop. If from Tab, maybe switch tab?
            // Since it's a tab, we probably don't want to pop unless it's full screen modal.
            // But layout design suggests it might be a modal.
            // For now, I'll leave it as is or maybe remove leading if it's main tab.
            // If it is a tab, leading close might not make sense.
            // I'll keep it simple for now.
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_off, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview Placeholder
          Positioned.fill(
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.camera_alt, color: Colors.grey, size: 64),
              ),
              // TODO: Integrate CameraPreview from camera package
            ),
          ),

          // Scanner Overlay
          const Positioned.fill(child: ScannerOverlay()),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Point your camera at a plant',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.image_outlined,
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: () {
                          // Trigger Scan Action
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      _buildControlButton(
                        icon: Icons.cached_rounded, // Flip camera
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
