import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PesticideCalculatorScreen extends StatefulWidget {
  const PesticideCalculatorScreen({super.key});

  @override
  State<PesticideCalculatorScreen> createState() => _PesticideCalculatorScreenState();
}

class _PesticideCalculatorScreenState extends State<PesticideCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _tankSizeController = TextEditingController();
  final _doseController = TextEditingController();
  
  String _dosageType = 'ml per Tank'; // or 'ml per Acre'
  
  double _totalWater = 0;
  double _totalChemical = 0;
  double _totalTanks = 0;
  bool _showResults = false;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      double area = double.tryParse(_areaController.text) ?? 0;
      double tankSize = double.tryParse(_tankSizeController.text) ?? 15;
      double dose = double.tryParse(_doseController.text) ?? 0;

      // Assumptions:
      // Standard water requirement per acre is often 150-200 Liters for field crops. 
      // Let's assume 150 Liters per acre as a baseline for calculation if dose is per acre.
      double waterPerAcre = 150; 

      if (_dosageType == 'ml per Tank') {
         // User says: put 50ml in 15L tank.
         // 1. Calculate how many tanks needed for area.
         // Liters needed = Area * 150 (approx standard). 
         // Tanks = Liters / TankSize.
         _totalWater = area * waterPerAcre;
         _totalTanks = _totalWater / tankSize;
         
         // Chemical needed = Tanks * Dose per Tank
         _totalChemical = _totalTanks * dose;

      } else {
        // Dosage type: 'ml per Acre'
        // User says: 500ml per Acre.
        _totalChemical = area * dose;
        _totalWater = area * waterPerAcre;
        _totalTanks = _totalWater / tankSize;
      }

      setState(() {
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: const Text('Pesticide Calculator'),
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
              _buildInputCard(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Calculate Spraying Mix', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              if (_showResults) _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _areaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Area to Spray (Acres)',
              border: OutlineInputBorder(),
              suffixText: 'Acres'
            ),
            validator: (v) => v!.isEmpty ? 'Enter area' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tankSizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tank Capacity',
              border: OutlineInputBorder(),
              suffixText: 'Liters'
            ),
            validator: (v) => v!.isEmpty ? 'Enter size' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _doseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Chemical Dose',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter dose' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _dosageType,
                  isExpanded: true,
                  items: ['ml per Tank', 'ml per Acre']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _dosageType = v!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spraying Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          _buildResultRow('Total Chemical Required', '${_totalChemical.toStringAsFixed(1)} ml'),
          _buildResultRow('Total Water Required', '${_totalWater.toStringAsFixed(0)} Liters'),
          _buildResultRow('Tank Refills Needed', '${_totalTanks.ceil()} Tanks'),
          const SizedBox(height: 10),
          const Text('⚠️ Always wear protective gear (mask, gloves) while spraying.', style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
