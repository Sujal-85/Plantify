import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'My Bookmarks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Plants'),
                Tab(text: 'Articles'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlantsList(),
          _buildArticlesList(),
        ],
      ),
    );
  }

  Widget _buildPlantsList() {
    final plants = [
      {'name': 'Prayer Plant', 'scientific': 'Goeppertia orbifolia', 'type': 'Foliage Plants'},
      {'name': 'Desert Agave', 'scientific': 'Agave deserti', 'type': 'Succulents & Cacti'},
      {'name': 'Peacock Plant', 'scientific': 'Goeppertia makoyana', 'type': 'Foliage Plants'},
      {'name': 'Aloe Vera', 'scientific': 'Aloe vera', 'type': 'Succulents & Cacti'},
      {'name': 'Night-Blooming Cereus', 'scientific': 'Acanthocereus tetragonus', 'type': 'Succulents & Cacti'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: plants.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final plant = plants[index];
        return Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.eco, color: AppColors.primary, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant['scientific']!,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    plant['type']!,
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        );
      },
    );
  }

  Widget _buildArticlesList() {
    final articles = [
      {
        'title': 'Unlock the Secrets of Succulents: Care Tips for Thriving Beauties',
        'image': 'Succulent Care'
      },
      {
        'title': 'Plant Parenthood: Choosing the Perfect Plant for Your Lifestyle',
        'image': 'Choosing Plants'
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: articles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final article = articles[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.article_outlined, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    article['title']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
