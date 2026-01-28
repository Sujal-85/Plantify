import 'package:flutter/material.dart';
import 'package:plant_analysis/features/home/screens/survey_screen.dart';

class SurveyCard extends StatefulWidget {
  const SurveyCard({super.key});

  @override
  State<SurveyCard> createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8FF), // Light blue/lavender background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration placeholder or Asset
              // Since I don't have the exact asset, I'll use an Icon or leave a placeholder space
              // defined by the layout. The user image shows a person picking fruit.
             Expanded(
               flex: 3,
               child: Row(
                  children: [
                    // Illustration
                    Image.asset(
                      'assets/images/app_logo.png', // Temporary placeholder if specific asset not available, or use Icon
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.volunteer_activism, size: 50, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: const Text(
                        'Help us make a better app for your farming needs.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF001C39),
                        ),
                      ),
                    ),
                  ],
               ),
             ),
              // Close X
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isVisible = false;
                  });
                },
                child: const Icon(Icons.close, color: Colors.black54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SurveyScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056D2), // Dark blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Take a survey',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
