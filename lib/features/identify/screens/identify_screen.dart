import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_colors.dart';
import 'identify_processing_screen.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // Permission Handling (simplified for brevity)
    if (source == ImageSource.camera) {
      if (await Permission.camera.request().isDenied) return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IdentifyProcessingScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Identify Plant', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/lottie/IT_Eco_Plant.json', height: 120),
            const SizedBox(height: 32),
            Text(
              'What plant is this?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Take a photo or upload an image to identify plants instantly using our Hybrid AI.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 48),
            _buildButton(
              label: 'Take Photo',
              icon: Icons.camera_alt,
              onTap: () => _pickImage(ImageSource.camera),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildButton(
              label: 'Upload from Gallery',
              icon: Icons.photo_library,
              onTap: () => _pickImage(ImageSource.gallery),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: 250,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isPrimary ? Colors.white : AppColors.primary),
        label: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : AppColors.primary)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          side: isPrimary ? null : const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: isPrimary ? 8 : 0,
        ),
      ),
    );
  }
}
