import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../plant_id/screens/plant_id_screen.dart';
import '../../disease_detection/screens/disease_result_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context,
              title: 'Identify\nPlant',
              icon: Icons.camera_alt_rounded,
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PlantIdScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              context,
              title: 'Heal\nPlants',
              icon: Icons.health_and_safety_rounded,
              color: const Color(0xFFF4A261), // Orange/Warning color
              onTap: () {
                // For now directly to result to show UI
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DiseaseResultScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
