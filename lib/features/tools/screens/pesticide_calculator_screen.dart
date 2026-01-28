import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'pesticide_sub_screens.dart';

class PesticideCalculatorScreen extends StatefulWidget {
  const PesticideCalculatorScreen({super.key});

  @override
  State<PesticideCalculatorScreen> createState() => _PesticideCalculatorScreenState();
}

class _PesticideCalculatorScreenState extends State<PesticideCalculatorScreen> {
  int _selectedType = -1; // 0 for Field crops, 1 for Trees

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pesticide calculator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              'What type of crop do you want to calculate pesticide dosage for?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSelectionCard(
                    0,
                    Icons.agriculture_outlined,
                    'Field crops',
                    'Calculate dosage based on area planted with field crops',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectionCard(
                    1,
                    Icons.forest_outlined,
                    'Trees',
                    'Calculate dosage based on amount of water for all trees to treat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Illustration Area
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9F8), // Light mint/teal bg
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Placeholder for the spray bottle illustration
                    // Using Icons to simulate the illustration for now
                    Positioned(
                      left: 50,
                      bottom: 50,
                      child: Icon(Icons.cleaning_services, size: 80, color: Colors.teal.shade300),
                    ),
                     Positioned(
                      right: 60,
                      bottom: 40,
                      child: Icon(Icons.coffee_rounded, size: 50, color: Colors.teal.shade200), // simulate measuring cup
                    ),
                    Positioned(
                       top: 40,
                       right: 40,
                       child: Icon(Icons.bubble_chart, size: 20, color: Colors.teal.shade100),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Recent calculations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your recent calculations will appear here. Compare them to see how changes in total product, dose per pump, and pump refills.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(int index, IconData icon, String title, String description) {
    final isSelected = _selectedType == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FieldCropsScreen()));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TreesScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 200, // Fixed height to match screenshot
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF3F51B5)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
