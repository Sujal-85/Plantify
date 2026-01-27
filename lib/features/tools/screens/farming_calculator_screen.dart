import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FarmingCalculatorScreen extends StatefulWidget {
  const FarmingCalculatorScreen({super.key});

  @override
  State<FarmingCalculatorScreen> createState() => _FarmingCalculatorScreenState();
}

class _FarmingCalculatorScreenState extends State<FarmingCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _rowSpacingController = TextEditingController();
  final _plantSpacingController = TextEditingController();
  final _testWeightController = TextEditingController();

  String _spacingUnit = 'Feet'; // Feet, Inches, cm
  
  double _totalPlants = 0;
  double _seedRateKg = 0;
  bool _showResults = false;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      double areaAcres = double.tryParse(_areaController.text) ?? 0;
      double row = double.tryParse(_rowSpacingController.text) ?? 0;
      double plant = double.tryParse(_plantSpacingController.text) ?? 0;
      double testWeight = double.tryParse(_testWeightController.text) ?? 0; // Wt of 1000 seeds in grams

      // 1. Convert Spacing to Sq. Feet
      double areaPerPlantSqFt = 0;

      if (_spacingUnit == 'Feet') {
        areaPerPlantSqFt = row * plant;
      } else if (_spacingUnit == 'Inches') {
        areaPerPlantSqFt = (row / 12) * (plant / 12);
      } else if (_spacingUnit == 'cm') {
        areaPerPlantSqFt = (row / 30.48) * (plant / 30.48);
      }

      // 1 Acre = 43,560 Sq Feet
      double plantsPerAcre = 43560 / areaPerPlantSqFt;
      _totalPlants = plantsPerAcre * areaAcres;

      // 2. Calculate Seed Rate
      // Seeds needed = Total Plants (assuming 1 seed per hole for simplicity, usually +10% gap filling)
      // Wt in g = (Total Seeds / 1000) * TestWeight
      // Kg = Wt / 1000
      
      double totalSeeds = _totalPlants; 
      double weightGrams = (totalSeeds / 1000) * testWeight;
      _seedRateKg = weightGrams / 1000;

      setState(() {
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farming Calculator'),
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
                child: const Text('Calculate Population', style: TextStyle(fontSize: 16, color: Colors.white)),
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
              labelText: 'Field Area (Acres)',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.isEmpty ? 'Req' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rowSpacingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Row Spacing',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Req' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _plantSpacingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Plant Spacing',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Req' : null,
                ),
              ),
            ],
          ),
           const SizedBox(height: 10),
           DropdownButtonFormField<String>(
              value: _spacingUnit,
              items: ['Feet', 'Inches', 'cm']
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _spacingUnit = v!),
              decoration: const InputDecoration(
                labelText: 'Spacing Unit',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
           TextFormField(
            controller: _testWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Test Weight (g per 1000 seeds)',
              border: OutlineInputBorder(),
              hintText: 'e.g., Wheat ~40g, Maize ~250g'
            ),
            validator: (v) => v!.isEmpty ? 'Req' : null,
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          _buildResultRow('Total Plants Required', _totalPlants.ceil().toString()),
          _buildResultRow('Seed Rate Required', '${_seedRateKg.toStringAsFixed(2)} kg'),
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
