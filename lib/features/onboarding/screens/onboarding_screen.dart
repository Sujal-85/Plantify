import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/onboarding_item.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Identify Plants',
      description:
          'Scan or upload a photo to instantly identify thousands of plants with high accuracy.',
      icon: Icons.camera_alt_rounded,
    ),
    OnboardingItem(
      title: 'Disease Detection',
      description:
          'Diagnose plant problems and get treatment tips to keep your green friends healthy.',
      icon: Icons.health_and_safety_rounded,
    ),
    OnboardingItem(
      title: 'Care Guides',
      description:
          'Get personalized care schedules for watering, fertilizing, and more.',
      icon: Icons.water_drop_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == _items.length - 1;
            });
          },
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return _buildPage(_items[index]);
          },
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        height: 160,
        color: AppColors.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmoothPageIndicator(
              controller: _controller,
              count: _items.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.surfaceGreen,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
                spacing: 8,
              ),
            ),
            const SizedBox(height: 24),
            isLastPage
                ? SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Get Started'),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () =>
                            _controller.jumpToPage(_items.length - 1),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              item.icon as IconData,
              size: 100,
              color: AppColors.primary,
            ),
            // TODO: Replace with actual Image asset when available
            // child: Image.asset(item.imagePath!, fit: BoxFit.cover),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
