import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildDateHeader(),
          const SizedBox(height: 24),
          _buildReminderItem(
            plantName: 'Snake Plant',
            action: 'Watering',
            time: '09:00 AM',
            isDone: false,
          ),
          _buildReminderItem(
            plantName: 'Aloe Vera',
            action: 'Fertilizing',
            time: '10:00 AM',
            isDone: true,
          ),
          _buildReminderItem(
            plantName: 'Monstera',
            action: 'Mist Leaves',
            time: '02:00 PM',
            isDone: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text('Oct 24, 2023', style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_today, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildReminderItem({
    required String plantName,
    required String action,
    required String time,
    required bool isDone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDone
            ? Border.all(color: AppColors.divider.withOpacity(0.5))
            : null,
        boxShadow: isDone
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDone ? Colors.grey[100] : AppColors.surfaceGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop,
              color: isDone ? Colors.grey : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDone ? Colors.grey : AppColors.textDark,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '$action • $time',
                  style: TextStyle(
                    color: isDone ? Colors.grey : AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isDone,
            onChanged: (val) {},
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
