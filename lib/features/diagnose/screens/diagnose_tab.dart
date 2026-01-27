import 'package:flutter/material.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';
import '../../scan/screens/scan_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../home/screens/ai_assistant_screen.dart';
import '../../home/screens/ai_assistant_welcome_screen.dart';
import '../../../core/services/preference_service.dart';
import 'package:provider/provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../core/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../home/screens/dashboard_screen.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';

class DiagnoseTab extends StatelessWidget {
  const DiagnoseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or a subtle gradient container as body wrapper
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
             if (Navigator.canPop(context)) {
                Navigator.pop(context);
             } else {
                DashboardScreenState.updateIndex(context, 0);
             }
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.diagnosis,
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined, color: Colors.black),
            onPressed: () {
               // Backend Button functionality (Placeholder)
               showDialog(
                 context: context, 
                 builder: (_) => AlertDialog(
                   title: Text(AppLocalizations.of(context)!.cloudSync),
                   content: Text(AppLocalizations.of(context)!.connectingServices),
                   actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.ok))]
                 )
               );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate network refresh
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check Your Plant Hero Card (Glass)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(24),
                color: AppColors.primary.withOpacity(0.05),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.checkYourPlant,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.checkYourPlantSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ScanScreen(isIdentifyMode: false)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 0,
                            ),
                            child: Text(AppLocalizations.of(context)!.diagnosis, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                             BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20),
                          ],
                        ),
                        child: const Icon(Icons.local_florist, color: AppColors.primary, size: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Common Diseases Section
            _buildSectionHeader(context, AppLocalizations.of(context)!.commonDiseases),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildDiseaseCard(context, 'Abiotic Stress', 'Environmental factors'),
                  _buildDiseaseCard(context, 'Fungal Infection', 'Mold & Mildew'),
                  _buildDiseaseCard(context, 'Bacterial Blight', 'Leaf spots & Wilt'),
                  _buildDiseaseCard(context, 'Viral Disease', 'Mosaic Patterns'),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideX(),

            const SizedBox(height: 32),

            // Ask Expert Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Material(
                 color: Colors.transparent,
                 child: InkWell(
                    onTap: () {
                        final prefs = Provider.of<PreferenceService>(context, listen: false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => prefs.hasSeenAIAssistantWelcome
                                ? const AIAssistantScreen()
                                : const AIAssistantWelcomeScreen(),
                          ),
                        );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFFE3E8FF).withOpacity(0.4),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF3D45C5), size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.askExpert,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: const Color(0xFF3D45C5)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.askExpertSubtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF3D45C5)),
                        ],
                      ),
                    ),
                 ),
              ),
            ).animate(delay: 300.ms).fadeIn().scale(),

            const SizedBox(height: 32),

            // Explore Diseases Grid
            _buildSectionHeader(context, AppLocalizations.of(context)!.exploreDiseases),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildCategoryCard(context, 'Whole Plant', Icons.eco_outlined),
                _buildCategoryCard(context, 'Leaves', Icons.energy_savings_leaf_outlined),
                _buildCategoryCard(context, 'Flowers', Icons.local_florist_outlined),
                _buildCategoryCard(context, 'Fruits', Icons.apple_outlined),
                _buildCategoryCard(context, 'Stems', Icons.segment_outlined),
                _buildCategoryCard(context, 'Roots', Icons.waves_outlined),
              ],
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 40),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          /*
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                Text(
                  'View All', 
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary, 
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
              ],
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(BuildContext context, String name, String subtitle) {
    return GestureDetector(
      onTap: () => _showGeminiInfo(context, name, "Tell me about the plant disease/issue: $name. Explain common symptoms and causes concisely."),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Icon(Icons.bug_report_outlined, color: AppColors.primary, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14)
                  ),
                  Text(
                    subtitle, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () => _showGeminiInfo(context, title, "What are common diseases that affect plant $title? Provide a brief list and description."),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
           boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const Spacer(),
            Text(
              title, 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13)
            ),
          ],
        ),
      ),
    );
  }

  void _showGeminiInfo(BuildContext context, String title, String prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: FutureBuilder<String>(
                  future: context.read<GeminiService>().chat(prompt, []),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text("Asking Plant Expert AI..."),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return Markdown(
                      data: snapshot.data ?? 'No info available.',
                      controller: controller,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
