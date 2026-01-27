
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../plant_details/screens/plant_details_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String imagePath;
  final String label;
  final double confidence;
  final String? description;
  final String? recommendation;

  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.label,
    required this.confidence,
    this.description,
    this.recommendation,
  });

  bool get isHealthy => label.toLowerCase().contains('healthy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Or go home
        ),
        title: const Text("Result", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Card
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath),
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            
            // Result Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: confidence > 0.7 ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHealthy ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    color: isHealthy ? AppColors.success : AppColors.error,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description / Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHealthy ? "Great Job! 🎉" : "Attention Needed ⚠️",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isHealthy ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description ?? (isHealthy 
                        ? "Your plant looks healthy. Keep up the good care!" 
                        : "We detected symptoms of $label. Check the details for treatment options."),
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  if (recommendation != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Recommendation:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation!,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => PlantDetailsScreen(
                         label: label,
                         imagePath: imagePath,
                         isHealthy: isHealthy,
                       ),
                     ),
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("View Treatment & Care", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add to My Plants Logic
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to My Plants!")));
                },
                icon: const Icon(Icons.bookmark_border),
                label: const Text("Save to My Plants"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
