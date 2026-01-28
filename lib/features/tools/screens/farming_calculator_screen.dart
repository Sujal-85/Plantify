import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'farming_sub_screens.dart';

class FarmingCalculatorScreen extends StatefulWidget {
  const FarmingCalculatorScreen({super.key});

  @override
  State<FarmingCalculatorScreen> createState() => _FarmingCalculatorScreenState();
}

class _FarmingCalculatorScreenState extends State<FarmingCalculatorScreen> {
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
              'Farming calculator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              'What do you want to calculate?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8, // Adjust aspect ratio to fit content
              children: [
                _buildOptionCard(
                  Icons.currency_rupee, // Using Rupee symbol as in screenshot
                  'Maximum input budget',
                  'How much you can spend on inputs',
                  const Color(0xFFE8EAF6),
                  const Color(0xFF3949AB),
                ),
                _buildOptionCard(
                  Icons.eco_outlined,
                  'Required yield',
                  'How much you need to harvest to cover expenses',
                  const Color(0xFFE3F2FD),
                  const Color(0xFF1E88E5),
                ),
                _buildOptionCard(
                  Icons.storefront_outlined,
                  'No loss price',
                  'The lowest price you should sell at to avoid loss',
                  const Color(0xFFE8F5E9),
                  const Color(0xFF2E7D32), // Darker green icon
                  iconBgOverride: const Color(0xFFE1F5FE), // Light blue background for icon in screenshot
                  iconColorOverride: const Color(0xFF1565C0), // Blue icon
                ),
                _buildOptionCard(
                  Icons.auto_graph_outlined,
                  'Estimated Profit',
                  'How much profit you will make after covering expenses',
                  const Color(0xFFF3E5F5),
                  const Color(0xFF8E24AA),
                  iconBgOverride: const Color(0xFFF3E5F5),
                  iconColorOverride: const Color(0xFF5E35B1),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Illustration with "Recent calculations" text below/overlayed
             Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5F3), // Light greenish/grey bg from screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Illustration Placeholder
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Plants
                        Positioned(
                          left: 40,
                          bottom: 20,
                          child: Row(
                            children: [
                               Icon(Icons.grass, size: 40, color: Colors.green.shade300),
                               Icon(Icons.grass, size: 50, color: Colors.green.shade400),
                               Icon(Icons.grass, size: 40, color: Colors.green.shade300),
                            ],
                          ),
                        ),
                        // Chart bars
                        Positioned(
                          right: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(width: 15, height: 30, color: Colors.green.shade100),
                              const SizedBox(width: 5),
                              Container(width: 15, height: 50, color: Colors.green.shade200),
                              const SizedBox(width: 5),
                              Container(width: 15, height: 70, color: Colors.green.shade300),
                            ],
                          ),
                        ),
                         // Rupee Coin
                        Positioned(
                          top: 0,
                          right: 40,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFC8E6C9),
                                child: Text('₹', style: TextStyle(color: Colors.green.shade800, fontSize: 24, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recent calculations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your recent calculations will appear here. Compare them to see how changes in yield, price, or expenses affect profit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      IconData icon, String title, String description, Color bg, Color accent,
      {Color? iconBgOverride, Color? iconColorOverride}) {
    // Note: The screenshot shows white cards with colored icon backgrounds
    const cardColor = Colors.white;
    final iconBg = iconBgOverride ?? const Color(0xFFE8EAF6);
    final iconColor = iconColorOverride ?? const Color(0xFF3949AB);

    return GestureDetector(
      onTap: () {
        if (title.contains('Maximum input')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MaxInputBudgetScreen()));
        } else if (title.contains('Required yield')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RequiredYieldScreen()));
        } else if (title.contains('No loss price')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NoLossPriceScreen()));
        } else if (title.contains('Estimated Profit')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EstimatedProfitScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded( // Ensure description takes available space properly
              child: Text(
                description,
                style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.3),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
