import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasResults = false;
  bool _isSearching = false;
  final List<String> _recentSearches = [
    'Night-blooming cereus',
    'Chinese anemone',
    'Silver wormwood',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.surface 
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
                _hasResults = value.toLowerCase().contains('plant');
              });
            },
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5)),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                          _hasResults = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildSearchInitial(),
    );
  }

  Widget _buildSearchInitial() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _recentSearches.clear()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((search) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(search, style: Theme.of(context).textTheme.bodyMedium),
                trailing: Icon(Icons.close, size: 18, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.4)),
                onTap: () {
                  _searchController.text = search;
                  setState(() {
                    _isSearching = true;
                    _hasResults = true;
                  });
                },
              )),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildCategoryCard('Succulents & Cacti', '🌵'),
              _buildCategoryCard('Flowering Plants', '🌸'),
              _buildCategoryCard('Foliage Plants', '🌿'),
              _buildCategoryCard('Trees', '🌲'),
              _buildCategoryCard('Weeds', '🌱'),
              _buildCategoryCard('Fruits', '🍎'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String label, String emoji) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : Colors.grey[200]!,
          width: 0.5
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.assignment_outlined, size: 120, color: AppColors.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 24),
            const Text(
              'No Plants Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Check your keywords or try searching with another keywords.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        return _buildPlantResultItem(index);
      },
    );
  }

  Widget _buildPlantResultItem(int index) {
    final plants = [
      {'name': 'Prayer Plant', 'scientific': 'Goeppertia orbifolia', 'type': 'Foliage Plants'},
      {'name': 'Corn Plant (Happy Plant)', 'scientific': 'Dracaena fragrans', 'type': 'Foliage Plants'},
      {'name': 'Jade Plant (Dollar Plant)', 'scientific': 'Crassula ovata', 'type': 'Foliage Plants'},
      {'name': 'Ghost Plant', 'scientific': 'Graptopetalum paraguayense', 'type': 'Succulents & Cacti'},
      {'name': 'Zebra Plant', 'scientific': 'Haworthiopsis fasciata', 'type': 'Succulents & Cacti'},
    ];
    final plant = plants[index % plants.length];

    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.surface 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant['name']!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                plant['scientific']!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  plant['type']!,
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.2)),
      ],
    );
  }
}
