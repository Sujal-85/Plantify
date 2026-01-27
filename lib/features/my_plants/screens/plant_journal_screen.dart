import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';

class PlantJournalScreen extends StatefulWidget {
  const PlantJournalScreen({super.key});

  @override
  State<PlantJournalScreen> createState() => _PlantJournalScreenState();
}

class _PlantJournalScreenState extends State<PlantJournalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final String plantName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Prayer Plant';

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
          'My Plant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'remove') _showDeleteConfirmation(context, plantName);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Edit Plant Name')])),
              const PopupMenuItem(value: 'photo', child: Row(children: [Icon(Icons.photo_outlined, size: 20), SizedBox(width: 12), Text('Change Cover Photo')])),
              const PopupMenuItem(
                value: 'remove', 
                child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 12), Text('Remove from My Plants', style: TextStyle(color: Colors.red))])
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Image
          Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.green[50],
                child: const Icon(Icons.eco, color: AppColors.primary, size: 80),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plantName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildMetaRow('Genus', 'Calathea'),
                _buildMetaRow('Scientific Name', 'Goeppertia orbifolia'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSubTabBar(),
            Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJournalTab(),
                _buildRemindersTab(),
                const Center(child: Text('Plant Info (Coming Soon)')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTab() {
    final reminders = [
      {'title': 'Watering', 'time': 'Dec 25, 2023 · 08:00 AM', 'icon': Icons.water_drop, 'color': Colors.blue, 'enabled': true},
      {'title': 'Fertilizing', 'time': 'Dec 26, 2023 · 04:00 PM', 'icon': Icons.grain, 'color': Colors.pink, 'enabled': true},
      {'title': 'Misting', 'time': 'Dec 27, 2023 · 10:00 AM', 'icon': Icons.auto_awesome, 'color': Colors.purple, 'enabled': true},
      {'title': 'Rotating', 'time': 'Set a reminder to rotate', 'icon': Icons.wb_sunny, 'color': Colors.orange, 'enabled': false},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final bool isEnabled = reminder['enabled'] as bool;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/set_reminder'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50], 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (reminder['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(reminder['icon'] as IconData, size: 20, color: reminder['color'] as Color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        isEnabled ? 'Next: ${reminder['time']}' : 'Tap to set reminder',
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (val) {
                    setState(() {
                      // In a real app, we would update the backend/local db
                      (reminders[index])['enabled'] = val;
                      if (val) {
                        NotificationService().showInstantNotification(
                          id: index, 
                          title: 'Reminder Enabled', 
                          body: 'Care reminder for ${reminder['title']} is now active.'
                        );
                      }
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 13))),
          const Text(':  ', style: TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSubTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.black54,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [Tab(text: 'Journal'), Tab(text: 'Reminders'), Tab(text: 'Plant Info')],
      ),
    );
  }

  Widget _buildJournalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.add, color: AppColors.primary), SizedBox(width: 8), Text('Add Action', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Watering', 'Fertilizing', 'Misting'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 12),
          child: FilterChip(
            selected: index == 0,
            label: Text(filters[index]),
            onSelected: (_) {},
            backgroundColor: Colors.grey[50],
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: index == 0 ? AppColors.primary : Colors.black87,
              fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: index == 0 ? AppColors.primary : Colors.grey[200]!)),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final actions = [
      {'title': 'Watering', 'time': 'Yesterday · 07:30 AM', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'title': 'Fertilizing', 'time': 'Dec 21, 2023 · 10:00 PM', 'icon': Icons.grain, 'color': Colors.pink},
      {'title': 'Photo', 'time': 'Dec 20, 2023 · 08:00 AM', 'icon': Icons.camera_alt_outlined, 'color': Colors.green, 'hasImages': true},
      {'title': 'Misting', 'time': 'Dec 19, 2023 · 09:45 AM', 'icon': Icons.auto_awesome, 'color': Colors.purple},
      {'title': 'Note', 'time': 'Dec 19, 2023 · 10:00 AM', 'icon': Icons.description_outlined, 'color': Colors.indigo, 'note': 'New shoots begin to give rise to branches and leaf petals. Plants grow well.'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                    ),
                    if (index != actions.length - 1)
                      Expanded(child: Container(width: 2, color: AppColors.primary.withValues(alpha: 0.2))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: (action['color'] as Color).withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Icon(action['icon'] as IconData, size: 16, color: action['color'] as Color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(action['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(action['time'] as String, style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 11)),
                                ],
                              ),
                            ),
                            const Icon(Icons.more_horiz, color: Colors.black26),
                          ],
                        ),
                        if (action.containsKey('note')) ...[
                          const SizedBox(height: 12),
                          Text(action['note'] as String, style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 13, height: 1.5)),
                        ],
                        if (action.containsKey('hasImages')) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(3, (i) => Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.image, color: Colors.black12, size: 24),
                            )),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String plantName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            const Text('Remove from My Plants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 24),
            Text(
              'Are you sure you want to remove "$plantName" from My Plants?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 16),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: const Text('Yes, Remove'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
