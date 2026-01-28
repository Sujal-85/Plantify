import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  State<FertilizerCalculatorScreen> createState() => _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends State<FertilizerCalculatorScreen> {
  String _selectedCrop = 'Banana';
  int _numberOfTrees = 0;
  final TextEditingController _treeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _treeController.text = _numberOfTrees > 0 ? '$_numberOfTrees' : '';
  }

  void _updateTrees(int delta) {
    setState(() {
      _numberOfTrees += delta;
      if (_numberOfTrees < 0) _numberOfTrees = 0;
      _treeController.text = _numberOfTrees > 0 ? '$_numberOfTrees' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              'Fertilizer Calculator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'See relevant information on',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCrop,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      isDense: true,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCrop = newValue!;
                        });
                      },
                      items: <String>['Banana', 'Mango', 'Coconut', 'Papaya']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Text(_getCropEmoji(value)), 
                              const SizedBox(width: 6),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nutrient quantities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.info_outline, size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Based on your field size and crop, we've selected a nutrient ratio for you",
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildNutrientCard('N:', '100 g', '100 g/tree')),
                const SizedBox(width: 12),
                Expanded(child: _buildNutrientCard('P:', '0 g', '0 g/tree')),
                const SizedBox(width: 12),
                Expanded(child: _buildNutrientCard('K:', '300 g', '300 g/tree')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Number of trees',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCounterButton(Icons.remove, () => _updateTrees(-1)),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5), // Light grey
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _treeController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          onChanged: (value) {
                            setState(() {
                              _numberOfTrees = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                        if (_numberOfTrees == 0 && _treeController.text.isEmpty)
                         SizedBox.shrink() // Don't show placeholder if just blank, wait for logic
                        else
                         const Text('Trees', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildCounterButton(Icons.add, () => _updateTrees(1)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Calculate logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.grey.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Calculate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            // Illustration
             _buildIllustration(),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getCropEmoji(String crop) {
    switch (crop) {
      case 'Banana': return '🍌';
      case 'Mango': return '🥭';
      case 'Coconut': return '🥥';
      case 'Papaya': return '🥔'; // Close enough default
      default: return '🌱';
    }
  }

  Widget _buildNutrientCard(String label, String amount, String rate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(rate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF3949AB)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
           // Hills
           Positioned(
             bottom: 0,
             child: CustomPaint(
               size: const Size(300, 80),
               painter: HillPainter(),
             ),
           ),
           // Trees
           Positioned(
             bottom: 30,
             left: 100,
             child: Icon(Icons.park, size: 60, color: Colors.teal.shade300),
           ),
           Positioned(
             bottom: 20,
             left: 150,
             child: Icon(Icons.park, size: 40, color: Colors.teal.shade200),
           ),
           Positioned(
             bottom: 40,
             left: 180,
             child: Icon(Icons.park, size: 80, color: Colors.teal.shade400),
           ),
            // Sun/Moon
             Positioned(
             top: 10,
             left: 60,
             child: Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: Colors.grey.shade200,
                 shape: BoxShape.circle,
               ),
             ),
           ),
        ],
      ),
    );
  }
}

class HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
