import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:plant_analysis/core/services/database_service.dart';
import 'package:plant_analysis/core/services/mongo_service.dart';
import 'package:plant_analysis/core/providers/user_provider.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';
import 'package:plant_analysis/widgets/glass_card.dart';
import 'history_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../home/screens/dashboard_screen.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  Future<List<Map<String, dynamic>>> _fetchHistory(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mongoService = Provider.of<MongoService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    try {
      final userId = userProvider.uid; // STRICT: Only use UID
      if (userId.isNotEmpty) { 
         final backendData = await mongoService.getUserScanResults(userId);
         if (backendData.isNotEmpty) {
           return backendData;
         }
      }
    } catch (e) {
      debugPrint('Error fetching backend history: $e');
    }
    
    // Fallback to local
    return await dbService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchHistory(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Resume rest of builder...

          final allHistory = snapshot.data ?? [];
          final filteredHistory = allHistory.where((item) {
            final name = item['diseaseName']?.toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              // Small delay to let the UI show the spinner
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildImmersiveAppBar(),
                // SearchBar is now part of AppBar
                
                if (filteredHistory.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.65, // Taller cards to fix overflow
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildHistoryCard(context, filteredHistory[index], index);
                        },
                        childCount: filteredHistory.length,
                      ),
                    ),
                  ),
                  
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImmersiveAppBar() {
    return SliverAppBar(
      expandedHeight: 220, // Increased for search bar space
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent, // Avoid tint on scroll
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
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 90), // Move title up to make room for bottom
        expandedTitleScale: 1.4,
        title: Text(
          AppLocalizations.of(context)!.historyTitle,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 10),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE3F2FD), // Light Blue
                    Color(0xFFE8F5E9), // Light Green
                    Colors.white,
                  ],
                ),
              ),
            ),
            // Abstract Pattern
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ),
             Positioned(
              left: -30,
              bottom: 20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          alignment: Alignment.bottomCenter,
          child: GlassCard(
            borderRadius: 16,
            blur: 10,
            padding: EdgeInsets.zero,
            color: Colors.grey[100]!.withOpacity(0.5),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHistory,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item, int index) {
    final date = DateTime.parse(item['date']);
    final formattedDate = DateFormat('MMM d').format(date);
    final isHealthy = item['confidence'] > 0.8; // Simplification

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryDetailScreen(scanItem: item),
          ),
        );
      },
      child: Dismissible(
        key: Key(item['id'].toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        onDismissed: (_) async {
           // Delete logic with Undo
           final db = context.read<DatabaseService>();
           await db.deleteHistoryItem(item['id']);
           
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(AppLocalizations.of(context)!.scanDeleted),
               action: SnackBarAction(
                 label: AppLocalizations.of(context)!.undo,
                 onPressed: () async {
                   // Restore logic - simplified by re-saving
                   await db.saveScan(item['imagePath'], item['diseaseName'], item['confidence']);
                   if (mounted) setState(() {}); // Refresh list
                 },
               ),
             ),
           );
           setState(() {}); // Refresh list to show removal
        },
        child: GlassCard(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          blur: 10,
          color: Colors.white.withOpacity(0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                flex: 3,
                child: Hero(
                  tag: item['imagePath'],
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.file(
                      File(item['imagePath']),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              // Content Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['diseaseName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isHealthy ? AppLocalizations.of(context)!.healthy : AppLocalizations.of(context)!.riskDetected,
                          style: TextStyle(
                            color: isHealthy ? Colors.green[800] : Colors.red[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noHistory,
            style: TextStyle(color: Colors.grey[500], fontSize: 18),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

// Delegate Removed
