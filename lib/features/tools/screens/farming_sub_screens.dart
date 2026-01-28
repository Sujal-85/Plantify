import 'package:flutter/material.dart';

// --- Maximum Input Budget Screen ---
class MaxInputBudgetScreen extends StatelessWidget {
  const MaxInputBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Maximum input budget', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Maximum input budget', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('₹0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInputRow('Yield', 'Your expected yield', '0', 'kg'),
            const SizedBox(height: 24),
            _buildInputRow('Selling price', 'How much you expect to earn per kg', '0', '₹/kg'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Calculate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            // Illustration placeholder
            Center(child: Icon(Icons.show_chart, size: 100, color: Colors.grey[200])), // Placeholder
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, String subLabel, String value, String unit) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(unit, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Required Yield Screen ---
class RequiredYieldScreen extends StatelessWidget {
  const RequiredYieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Required yield', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text('Required yield', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('0 kg', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInputRow('Expenses', 'Total money spent on inputs', '₹ 0'),
            const SizedBox(height: 24),
            _buildInputDropdownRow('Selling price', 'How much you expect to earn per kg', '0', '₹/kg'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                child: const Text('Calculate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
   Widget _buildInputRow(String label, String subLabel, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
   Widget _buildInputDropdownRow(String label, String subLabel, String value, String unit) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value), Row(children: [Text(unit), Icon(Icons.arrow_drop_down)])]),
          ),
        ),
      ],
    );
  }
}

// --- No Loss Price Screen ---
class NoLossPriceScreen extends StatelessWidget {
  const NoLossPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('No loss price', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text('No loss price', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('₹0 /kg', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
             _buildInputRow('Expenses', 'Total money spent on inputs', '₹ 0', null),
             const SizedBox(height: 24),
             _buildInputRow('Yield', 'Your expected yield', '0', 'kg'),
             const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056D2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                child: const Text('Calculate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputRow(String label, String subLabel, String value, String? unit) {
    return Row(
      children: [
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(subLabel, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]!), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
               Text(value, style: const TextStyle(fontSize: 16)),
               if (unit != null) Row(children: [Text(unit), Icon(Icons.arrow_drop_down)])
            ]),
          ),
        ),
      ],
    );
  }
}

// --- Estimated Profit Screen ---
class EstimatedProfitScreen extends StatelessWidget {
  const EstimatedProfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Estimated Profit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputDropdownRow('Yield', 'Your expected yield', '0', 'kg'),
            const SizedBox(height: 24),
            _buildInputDropdownRow('Selling price', 'How much you expect to earn per kg', '0', '₹/kg'),
            const SizedBox(height: 24),
            _buildTextInputRow('Expenses', 'Total money spent on inputs', '₹ 0'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Calculate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            // Illustration and Recent Calculations
             Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                   SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Placeholder for the illustration
                         Icon(Icons.bar_chart, size: 80, color: Colors.teal.shade200),
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
                         )
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

  Widget _buildInputDropdownRow(String label, String subLabel, String value, String unit) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subLabel, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(unit, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInputRow(String label, String subLabel, String hint) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subLabel, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), // Input field has internal padding
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
      ],
    );
  }
}
