import 'package:flutter/material.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';

class QuickstartScreen extends StatelessWidget {
  const QuickstartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quickstart Guide', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: PageView(
        children: [
          _buildPage(
            'Scan Your Plant',
            'Take a clear photo of the affected leaf area.',
            Icons.camera_alt_outlined,
            Colors.blue,
          ),
          _buildPage(
            'Get Diagnosis',
            'Our AI analyzes the disease instanty.',
            Icons.analytics_outlined,
            Colors.purple,
          ),
          _buildPage(
            'Apply Treatment',
            'Follow organic or chemical treatment plans.',
            Icons.healing_outlined,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
            child: Icon(icon, size: 80, color: color),
          ),
          const SizedBox(height: 32),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(desc, style: const TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
