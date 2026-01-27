import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:plant_analysis/core/disease_model.dart';
import 'package:plant_analysis/core/treatment_database.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> scanItem;

  const HistoryDetailScreen({super.key, required this.scanItem});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int? _surveyValue;
  Disease? _matchedDisease;

  @override
  void initState() {
    super.initState();
    _findDisease();
  }

  void _findDisease() {
    // Attempt to find disease by name in our mock database
    // In real app, we might store diseaseId in history
    final diseaseName = widget.scanItem['diseaseName'];
    try {
      _matchedDisease = diseaseDatabase.values.firstWhere(
        (d) => d.name.toLowerCase() == diseaseName.toString().toLowerCase(),
      );
    } catch (_) {
      // Fallback or create a dummy matching disease for demo logic if needed
      // For now, if not found, we show mostly defaults
      _matchedDisease = Disease(
        name: diseaseName,
        description: 'Identified from history scan.',
        severity: 'Unknown',
        imageUrl: widget.scanItem['imagePath'],
        treatmentSteps: [],
        pathogenType: 'Diagnosis',
        organicControl: 'Consult a local agricultural expert for organic solutions specific to this region.',
        chemicalControl: 'No specific chemical recommendations available in offline history.',
      );
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.scanItem['date']);
    final formattedDate = DateFormat('d MMMM').format(date);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
           TextButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('Share'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE3E8FF),
              foregroundColor: const Color(0xFF3D45C5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Diagnosis Result
            _buildSectionHeader('1', 'Diagnosis result'),
            _buildDiagnosisCard(),

             const SizedBox(height: 16),
            
            // Ask Plantix Assist Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Ask Plantix assist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3E8FF),
                  foregroundColor: const Color(0xFF3D45C5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2. Recommendations
            _buildSectionHeader('2', 'Recommendations'),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: [
                       const Text('See product information on', style: TextStyle(color: Colors.grey)),
                       const Spacer(),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey[300]!),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: const Row(
                           children: [
                             Icon(Icons.grass, size: 16, color: Colors.amber),
                             SizedBox(width: 4),
                             Text('Crop'),
                             Icon(Icons.keyboard_arrow_down, size: 16),
                           ],
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 12),
                   const Text(
                     'Recommendations based on historical diagnosis.',
                     style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                   ),
                   const SizedBox(height: 24),
                   
                   // Organic Control
                   _buildControlSection(
                     'Organic Control',
                     Icons.eco_outlined,
                     _matchedDisease?.organicControl ?? 'No data',
                     true,
                   ),
                   
                   const SizedBox(height: 24),
                   
                   // Chemical Control
                   _buildControlSection(
                     'Chemical Control',
                     Icons.science_outlined,
                     _matchedDisease?.chemicalControl ?? 'No data',
                     false,
                   ),
                ],
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF005C35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.scanItem['imagePath']),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 60, height: 60),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.scanItem['diseaseName'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _matchedDisease?.pathogenType ?? 'Diagnosis',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildControlSection(String title, IconData icon, String text, bool isOrganic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _speak(text),
          child: const Row(
            children: [
               Icon(Icons.volume_up, size: 20, color: Color(0xFF3D45C5)),
               SizedBox(width: 8),
               Text('Listen', style: TextStyle(color: Color(0xFF3D45C5), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.black54, height: 1.4)),
      ],
    );
  }
}
