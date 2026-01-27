
import 'package:plant_analysis/core/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';
import 'package:plant_analysis/core/services/database_service.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final String label = result['label'] ?? 'Unknown';
    final double confidence = result['confidence'] ?? 0.0;
    final String severity = confidence > 0.8 ? 'High' : 'Medium';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analysis Result'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Chemical'),
              Tab(text: 'Organic'),
              Tab(text: 'Prevention'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Image & Confidence
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.black12,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  displayImage(imagePath),
                  // TODO: Overlay Heatmap if available
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black87, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Confidence: ${(confidence * 100).toStringAsFixed(1)}% • Severity: $severity',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: context.read<DatabaseService>().getTreatments(label),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final treatments = snapshot.data ?? [];
                  
                  return TabBarView(
                    children: [
                      _buildTreatmentList(treatments, 'Chemical'),
                      _buildTreatmentList(treatments, 'Organic'),
                      _buildTreatmentList(treatments, 'Prevention'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentList(List<Map<String, dynamic>> allTreatments, String type) {
    final filtered = allTreatments.where((t) => t['type'] == type).toList();
    
    if (filtered.isEmpty) {
      return const Center(child: Text('No recommendations available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filtered[index]['instruction'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

