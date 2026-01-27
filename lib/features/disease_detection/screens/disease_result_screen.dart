import 'package:flutter/material.dart';
import 'package:plant_analysis/core/disease_model.dart';
import 'package:plant_analysis/core/treatment_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:plant_analysis/widgets/glass_card.dart';

class DiseaseResultScreen extends StatefulWidget {
  final String diseaseId;

  const DiseaseResultScreen({super.key, required this.diseaseId});

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int? _surveyValue; 

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
    final Disease? disease = diseaseDatabase[widget.diseaseId];

    if (disease == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Disease not found.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Can use a subtle gradient background here too
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(disease),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                   // Environmental Insight
                   _buildInsightCard().animate().slideX(begin: -0.2).fadeIn(duration: 500.ms),
                   const SizedBox(height: 24),
                   
                   // 1. Diagnosis Results
                   _buildSection(
                     '1', 
                     'Diagnosis result', 
                     _buildDiagnosisCard(disease),
                     delay: 100,
                   ),
                   
                   const SizedBox(height: 16),
                   
                   // Assist & Reminder Buttons
                   Row(
                     children: [
                       Expanded(
                         child: _buildAssistButton(),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: _buildReminderButton(),
                       ),
                     ],
                   ).animate(delay: 200.ms).fadeIn().scale(),

                   const SizedBox(height: 32),

                   // 2. Recommendations (Collapsible)
                   _buildRecommendationsSection(disease).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

                   const SizedBox(height: 32),

                   // Survey
                   _buildSurveySection().animate(delay: 400.ms).fadeIn(),
                   
                   const SizedBox(height: 48),
                   _buildFooterFeedback().animate(delay: 500.ms).fadeIn(),
                   const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(Disease disease) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black, // For back button
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              disease.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      disease.pathogenType.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    disease.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const GlassCard(
             padding: EdgeInsets.all(8),
             borderRadius: 50,
             blur: 5,
             child: Icon(Icons.share, color: Colors.white, size: 20),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const GlassCard(
             padding: EdgeInsets.all(8),
             borderRadius: 50,
             blur: 5,
             child: Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_queue, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('High Humidity Alert', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                Text('85% Humidity favors fungal steps.', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(12),
             ),
             child: const Text('RISK HIGH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String number, String title, Widget content, {int delay = 0}) {
     return Column(
       children: [
         Padding(
           padding: const EdgeInsets.only(bottom: 12),
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
         ),
         content,
       ],
     ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildDiagnosisCard(Disease disease) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             disease.description,
             style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
           ),
           const SizedBox(height: 12),
           Row(
             children: [
               _buildBadge(Icons.bug_report_outlined, disease.pathogenType),
               const SizedBox(width: 8),
               _buildBadge(Icons.warning_amber_rounded, disease.severity),
             ],
           )
        ],
      ),
    );
  }
  
  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildAssistButton() {
     return ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.auto_awesome, size: 16),
        label: const Text('Ai Assist'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE3E8FF),
          foregroundColor: const Color(0xFF3D45C5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
  }
  
  Widget _buildReminderButton() {
    return ElevatedButton.icon(
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder Set!')));
        },
        icon: const Icon(Icons.alarm, size: 16),
        label: const Text('Set Reminder'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF3E0),
          foregroundColor: Colors.orange[800],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 1000.ms);
  }

  Widget _buildRecommendationsSection(Disease disease) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF005C35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
         children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                   _buildControlCard(
                     'Organic Control',
                     Icons.eco_rounded,
                     Colors.green,
                     disease.organicControl,
                   ),
                   const SizedBox(height: 16),
                   _buildControlCard(
                     'Chemical Control',
                     Icons.science_rounded,
                     Colors.purple,
                     disease.chemicalControl,
                   ),
                ],
              ),
            ),
         ],
      ),
    );
  }

  Widget _buildControlCard(String title, IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                ],
              ),
              GestureDetector(
                onTap: () => _speak(text),
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                   child: Icon(Icons.volume_up_rounded, size: 20, color: color),
                 ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSurveySection() {
     return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: const Color(0xFFE3E8FF).withOpacity(0.5),
         borderRadius: BorderRadius.circular(24),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('Help us improve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
           const SizedBox(height: 16),
           const Text('How much of your crop looks damaged?', style: TextStyle(color: Colors.black54)),
           const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('None'),
                _buildChip('Few'),
                _buildChip('Some (<50%)'),
                _buildChip('Most (>50%)'),
                _buildChip('All'),
              ],
            ),
         ],
       ),
     );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide.none,
      elevation: 0,
    );
  }
  
  Widget _buildFooterFeedback() {
    return const Column(
      children: [
        Text('Was this diagnosis helpful?', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up_alt_outlined, size: 32, color: Colors.grey),
            SizedBox(width: 32),
            Icon(Icons.thumb_down_alt_outlined, size: 32, color: Colors.grey),
          ],
        )
      ],
    );
  }
}
