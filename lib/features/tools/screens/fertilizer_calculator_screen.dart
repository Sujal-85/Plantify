import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({super.key});

  @override
  State<FertilizerCalculatorScreen> createState() => _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState extends State<FertilizerCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();

  String _selectedUnit = 'Acres';
  double _ureaBags = 0;
  double _dapBags = 0;
  double _mopBags = 0;
  bool _showResults = false;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      double area = double.tryParse(_areaController.text) ?? 0;
      double n = double.tryParse(_nController.text) ?? 0;
      double p = double.tryParse(_pController.text) ?? 0;
      double k = double.tryParse(_kController.text) ?? 0;

      // Convert area to hectares for standardization if needed, 
      // but usually recommendations are per acre in India. 
      // Let's assume input NPK is kg/acre if unit is acre.
      
      // Standard: 
      // Urea = 46% N
      // DAP = 18% N, 46% P
      // MOP = 60% K
      // Bag size = 50kg (commonly) or 45kg (Neem coated Urea). Let's assume 50kg for now.
      
      double pNeeded = p * area;
      double kNeeded = k * area;
      double nNeeded = n * area;

      // 1. Calculate DAP (Phosphorus source)
      // DAP contains 46% P. So 100kg DAP = 46kg P. 
      // P needed = X kg. DAP needed = (X / 46) * 100.
      double dapKg = (pNeeded / 46) * 100;
      
      // DAP also provides 18% N.
      double nFromDap = (dapKg * 18) / 100;
      
      // 2. Calculate MOP (Potassium source)
      // MOP contains 60% K.
      double mopKg = (kNeeded / 60) * 100;

      // 3. Calculate Urea (Remaining Nitrogen)
      double remainingN = nNeeded - nFromDap;
      if (remainingN < 0) remainingN = 0;
      
      // Urea contains 46% N.
      double ureaKg = (remainingN / 46) * 100;

      setState(() {
        _dapBags = dapKg / 50;
        _mopBags = mopKg / 50;
        _ureaBags = ureaKg / 45; // Urea bags often 45kg now
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizer Calculator'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _areaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Land Area',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'Enter area' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            items: ['Acres', 'Hectares', 'Guntha']
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedUnit = v!),
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Recommended N-P-K (kg/acre)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildNpkField(_nController, 'N (Nitrogen)', Colors.blue[100]!)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNpkField(_pController, 'P (Phosphorus)', Colors.green[100]!)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNpkField(_kController, 'K (Potassium)', Colors.orange[100]!)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Calculate Required Bags', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              if (_showResults) ...[
                const SizedBox(height: 30),
                const Text('Required Fertilizers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildResultTile('Urea (45kg bag)', _ureaBags, Colors.blue),
                _buildResultTile('DAP (50kg bag)', _dapBags, Colors.green),
                _buildResultTile('MOP (50kg bag)', _mopBags, Colors.red),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNpkField(TextEditingController controller, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(10),
        ),
         validator: (v) => v!.isEmpty ? 'Req' : null,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _buildResultTile(String label, double bags, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${bags.toStringAsFixed(1)} Bags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
