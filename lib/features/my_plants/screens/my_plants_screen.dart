
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MyPlantsScreen extends StatefulWidget {
  const MyPlantsScreen({super.key});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final bool _hasPlants = true; // For demo purpose

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isFarmer = userProvider.isFarmer;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.eco, color: AppColors.primary, size: 28),
        ),
        title: Text(
          'My Plants',
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color, 
            fontWeight: FontWeight.bold, 
            fontSize: 24
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _hasPlants ? _buildPlantsList() : _buildEmptyState(),
                Center(
                  child: Text(
                    'Snap History (Coming Soon)', 
                    style: Theme.of(context).textTheme.bodyMedium
                  )
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/scan'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.surface 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Plants (12)'),
          Tab(text: 'Snap History (48)'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco, size: 100, color: AppColors.primary.withOpacity(0.2)),
        const SizedBox(height: 24),
        const Text(
          'You Have No Plants',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "You haven't added any plants yet.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildPlantsList() {
    final List<Map<String, dynamic>> plants = [
      {'name': 'Prayer Plant', 'scientific': 'Goeppertia orbifolia', 'icons': [Icons.water_drop, Icons.grain, Icons.auto_awesome]},
      {'name': 'Snake Plant', 'scientific': 'Sansevieria trifasciata', 'icons': [Icons.water_drop, Icons.grain, Icons.auto_awesome, Icons.wb_sunny]},
      {'name': 'Ghost Plant', 'scientific': 'Graptopetalum paraguayense', 'icons': [Icons.water_drop, Icons.wb_sunny]},
      {'name': 'Aloe Vera', 'scientific': 'Aloe vera', 'icons': [Icons.water_drop, Icons.grain, Icons.auto_awesome, Icons.wb_sunny]},
      {'name': 'Jade Plant', 'scientific': 'Crassula ovata', 'icons': [Icons.water_drop, Icons.wb_sunny]},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/plant_journal', arguments: plant['name']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.surface 
                        : Colors.grey[200],
                    child: Icon(
                      Icons.image, 
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white10 
                          : Colors.black12, 
                      size: 40
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plant['name'], style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(plant['scientific'], style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Row(
                        children: (plant['icons'] as List<IconData>).map((icon) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getIconColor(icon).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 14, color: _getIconColor(icon)),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: 16, 
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.2)
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getIconColor(IconData icon) {
    if (icon == Icons.water_drop) return Colors.blue;
    if (icon == Icons.grain) return Colors.pink;
    if (icon == Icons.auto_awesome) return Colors.purple;
    if (icon == Icons.wb_sunny) return Colors.orange;
    return AppColors.primary;
  }
}
