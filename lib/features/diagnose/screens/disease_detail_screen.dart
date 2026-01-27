import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DiseaseDetailScreen extends StatefulWidget {
  const DiseaseDetailScreen({super.key});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String diseaseName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Abiotic';

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
          diseaseName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.orange[50],
                child: const Icon(Icons.bug_report, color: Colors.orange, size: 80),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                diseaseName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Symptoms'),
              Tab(text: 'Causes'),
              Tab(text: 'Treatment'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Abiotic diseases are caused by non-living factors, impacting plant health due to adverse environmental conditions or improper care practices.'),
                _buildSymptomsTab(),
                _buildCausesTab(),
                _buildTreatmentTab(),
              ],
            ),
          ),
          _buildFeedbackSection(),
        ],
      ),
    );
  }

  Widget _buildTabContent(String text) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    return _buildBulletedTab('Symptoms', [
      'Yellowing or discoloration of leaves.',
      'Leaf burn or scorch.',
      'Stunted growth.',
      'Poor fruit development.',
    ]);
  }

  Widget _buildCausesTab() {
    return _buildBulletedTab('Causes', [
      'Environmental stress factors like extreme temperatures, drought, or waterlogging.',
      'Soil nutrient imbalances.',
      'Poor soil drainage.',
    ]);
  }

  Widget _buildTreatmentTab() {
    return _buildBulletedTab('Treatment and Management', [
      'Adjust care practices based on specific symptoms.',
      'Improve soil drainage.',
      'Provide proper irrigation and mulching.',
      'Use balanced fertilizers.',
      'Protect plants from extreme weather conditions.',
    ]);
  }

  Widget _buildBulletedTab(String title, List<String> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.circle, size: 6, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          const Text(
            'Was this helpful?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeedbackButton('Yes'),
              const SizedBox(width: 16),
              _buildFeedbackButton('No'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black87)),
    );
  }
}
