import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';

class IdentifyResultsScreen extends StatelessWidget {
  final String? imagePath;
  final Map<String, dynamic>? plantData;

  const IdentifyResultsScreen({super.key, this.imagePath, this.plantData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Fallback if null (shouldn't happen if called correctly)
    final data = plantData ?? {
      'name': 'Unknown Plant',
      'scientificName': 'Unknown',
      'description': 'No description available.',
      'uses': 'N/A'
    };
    final String image = imagePath ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.identifyResults, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Head Image
            if (image.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(image)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
               Container(height: 300, color: Colors.grey[200]),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    data['name'] ?? 'Unknown Plant',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['scientificName'] ?? 'Unknown',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                  if (data['indianName'] != null) ...[
                     const SizedBox(height: 8),
                     Text(
                      'Indian Name: ${data['indianName']}',
                      style: const TextStyle(fontSize: 16, color: AppColors.primary),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.description, Icons.description_outlined),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: data['description'] ?? 'No description available.',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.uses, Icons.eco_outlined),
                  const SizedBox(height: 12),
                  MarkdownBody(
                    data: data['uses'] ?? 'No information available.',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 20),
              const SizedBox(width: 8),
              Text(l10n.addToMyPlants, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
