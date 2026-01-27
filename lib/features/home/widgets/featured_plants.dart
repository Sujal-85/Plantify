import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'featured_plant_card.dart';

class FeaturedPlants extends StatelessWidget {
  const FeaturedPlants({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Plants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: const [
              FeaturedPlantCard(
                name: 'Aloe Vera',
                price: '\$12.99',
                imagePath: '',
              ),
              SizedBox(width: 16),
              FeaturedPlantCard(
                name: 'Monstera',
                price: '\$24.50',
                imagePath: '',
              ),
              SizedBox(width: 16),
              FeaturedPlantCard(
                name: 'Snake Plant',
                price: '\$18.00',
                imagePath: '',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
