import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Category';

    final List<Map<String, String>> plants = [
      {
        'name': 'Prayer Plant',
        'scientificName': 'Goeppertia orbifolia',
        'category': 'Foliage Plants',
        'image': 'https://images.unsplash.com/photo-1631501431690-e59178cc738a?q=80&w=200&auto=format&fit=crop',
      },
      {
        'name': 'Baby Rubber Plant',
        'scientificName': 'Peperomia obtusifolia',
        'category': 'Foliage Plants',
        'image': 'https://images.unsplash.com/photo-1602330041000-4b8109384732?q=80&w=200&auto=format&fit=crop',
      },
      {
        'name': 'Snake Plant',
        'scientificName': 'Sansevieria trifasciata',
        'category': 'Foliage Plants',
        'image': 'https://images.unsplash.com/photo-1593482892290-f54927ae1bf7?q=80&w=200&auto=format&fit=crop',
      },
      {
        'name': 'Swiss Cheese Plant',
        'scientificName': 'Monstera deliciosa',
        'category': 'Foliage Plants',
        'image': 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?q=80&w=200&auto=format&fit=crop',
      },
      {
        'name': 'Dumbcane',
        'scientificName': 'Dieffenbachia seguine',
        'category': 'Foliage Plants',
        'image': 'https://images.unsplash.com/photo-1604762524889-3e2fcc145683?q=80&w=200&auto=format&fit=crop',
      },
    ];

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
          categoryName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search plants...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: plants.length,
              separatorBuilder: (context, index) => const Divider(height: 32, color: Colors.black12),
              itemBuilder: (context, index) {
                final plant = plants[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/plant_info',
                    arguments: plant,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: plant['image']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.eco, color: AppColors.primary, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plant['scientificName']!,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              plant['category']!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
