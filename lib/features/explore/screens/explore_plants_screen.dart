import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';

class ExplorePlantsScreen extends StatelessWidget {
  const ExplorePlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Succulents\n& Cacti', 
        'icon': Icons.eco, 
        'color': Colors.green[100],
        'image': 'https://images.unsplash.com/photo-1520302630444-894a97750549?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Flowering\nPlants', 
        'icon': Icons.local_florist, 
        'color': Colors.pink[50],
        'image': 'https://images.unsplash.com/photo-1533276343516-7d4023c52a09?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Foliage\nPlants', 
        'icon': Icons.eco, 
        'color': Colors.green[50],
        'image': 'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Trees', 
        'icon': Icons.park, 
        'color': Colors.brown[50],
        'image': 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Weeds &\nShrubs', 
        'icon': Icons.grass, 
        'color': Colors.teal[50],
        'image': 'https://images.unsplash.com/photo-1524225569476-8806263884d9?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Fruits', 
        'icon': Icons.apple, 
        'color': Colors.orange[50],
        'image': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Vegetables', 
        'icon': Icons.agriculture, 
        'color': Colors.green[50],
        'image': 'https://images.unsplash.com/photo-1566385101042-1a0aa0c12e8c?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Herbs', 
        'icon': Icons.spa, 
        'color': Colors.lightGreen[50],
        'image': 'https://images.unsplash.com/photo-1507020995383-e2e71f5b3f2c?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Mushrooms', 
        'icon': Icons.cloud_circle, 
        'color': Colors.grey[100],
        'image': 'https://images.unsplash.com/photo-1504629403361-9c16b2404e57?q=80&w=400&auto=format&fit=crop'
      },
      {
        'title': 'Toxic Plants', 
        'icon': Icons.warning_amber_rounded, 
        'color': Colors.red[50],
        'image': 'https://images.unsplash.com/photo-1600122960641-7299a4e9b720?q=80&w=400&auto=format&fit=crop'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Flora', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plant Categories',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPremium,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover and learn about different species',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context, 
                      '/category_detail',
                      arguments: {'title': category['title']},
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: category['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Glass Title at the bottom
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: GlassCard(
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            blur: 10,
                            child: Row(
                              children: [
                                Icon(category['icon'], color: AppColors.accent, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category['title'].replaceAll('\n', ' '),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
