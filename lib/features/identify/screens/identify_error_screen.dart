import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class IdentifyErrorScreen extends StatelessWidget {
  final String? message;
  const IdentifyErrorScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_very_dissatisfied_rounded, color: AppColors.primary, size: 120),
                    // Adding eyes and mouth via Stack if needed, but the icon is a good placeholder
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              "We're sorry!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? "We cannot identify your plant. Try the photo again from a different angle.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 16, height: 1.5),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/scan'), // Or pop and push
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
