import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';

class DiagnosisResultsScreen extends StatefulWidget {
  const DiagnosisResultsScreen({super.key});

  @override
  State<DiagnosisResultsScreen> createState() => _DiagnosisResultsScreenState();
}

class _DiagnosisResultsScreenState extends State<DiagnosisResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate Diagnosis Completion Notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Diagnosis Completed',
        body: 'We have identified a possible issue with your plant: Abiotic.',
        iconName: 'shield',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Diagnosis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hotspots
            Padding(
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.black12, size: 80),
                    ),
                  ),
                  // Simulated Hotspots
                  _buildHotspot(top: 40, left: 140),
                  _buildHotspot(top: 60, left: 240),
                  _buildHotspot(top: 120, left: 190),
                  _buildHotspot(top: 220, left: 260),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Possible Disease Problems',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildDiseaseItem(
                    context,
                    'Abiotic',
                    'Abiotic diseases are caused by non-living factors, such as adverse environmental condit...',
                    isMostLikely: true,
                  ),
                  const Divider(height: 48),
                  _buildDiseaseItem(
                    context,
                    'Animalia',
                    'While most plant diseases are caused by fungi, bacteria, or viruses, there are some instan...',
                  ),
                  const Divider(height: 48),
                  _buildDiseaseItem(
                    context,
                    'Fungi',
                    'Fungal diseases are the most common cause of plant health issues, spreading through spores...',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
          child: const Text('Ask Experts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildHotspot({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 2),
          color: Colors.red.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildDiseaseItem(BuildContext context, String name, String snippet, {bool isMostLikely = false}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/disease_detail', arguments: name),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.bug_report_outlined, color: Colors.orange, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (isMostLikely) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                        ),
                        child: const Text(
                          'Most likely',
                          style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Center(child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26)),
        ],
      ),
    );
  }
}
