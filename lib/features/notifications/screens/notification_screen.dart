import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/database_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = context.read<DatabaseService>().getNotifications();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shield':
        return Icons.shield_outlined;
      case 'info':
        return Icons.info_outline;
      case 'lock':
        return Icons.lock_reset;
      case 'star':
        return Icons.star_border;
      case 'calendar':
        return Icons.calendar_today;
      case 'eco':
        return Icons.eco_outlined;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color, 
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      'assets/images/notification_empty.png', // Ensure this asset exists or use a robust fallback
                      width: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.notifications_off_outlined, size: 100, color: Colors.grey);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nothing found to show here.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final date = DateTime.parse(item['time']);
              final timeStr = DateFormat('hh:mm a').format(date);
              
              return _NotificationItem(
                icon: _getIconData(item['icon'] ?? 'notifications'),
                title: item['title'] ?? 'No Title',
                description: item['description'] ?? 'No Description',
                time: timeStr,
                isUnread: item['isUnread'] == 1,
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final bool isUnread;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.glassBorder 
                    : Colors.grey[200]!
              ),
              color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : null,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.2), size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: isUnread ? null : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
