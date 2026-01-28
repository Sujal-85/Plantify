import 'package:flutter/material.dart';
import 'package:plant_analysis/core/services/mongo_service.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Survey State
  String? _farmingType;
  final TextEditingController _cropsController = TextEditingController();
  final TextEditingController _challengesController = TextEditingController();
  double _satisfaction = 3.0;
  bool _isLoading = false;

  final List<String> _farmingTypes = [
    'Organic Farming',
    'Conventional Farming',
    'Hydroponics',
    'Home Gardening',
    'Other'
  ];

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final surveyData = {
      'farmingType': _farmingType,
      'primaryCrops': _cropsController.text,
      'biggestChallenge': _challengesController.text,
      'satisfactionRating': _satisfaction,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final success = await MongoService().submitSurvey(surveyData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit survey. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _cropsController.dispose();
    _challengesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantix Survey'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help us improve!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please answer a few questions about your farming experience.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Question 1
                  const Text('What type of farming do you practice?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _farmingType,
                    items: _farmingTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => _farmingType = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (val) => val == null ? 'Please select a farming type' : null,
                  ),
                  const SizedBox(height: 24),

                  // Question 2
                  const Text('Which crops do you primarily grow?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cropsController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Wheat, Rice, Tomatoes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter at least one crop' : null,
                  ),
                  const SizedBox(height: 24),

                  // Question 3
                  const Text('What is your biggest farming challenge?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _challengesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g. Pests, Water shortage, Market prices',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),

                   // Question 4
                  const Text('How satisfied are you with the app?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Slider(
                    value: _satisfaction,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _satisfaction.round().toString(),
                    onChanged: (val) => setState(() => _satisfaction = val),
                    activeColor: AppColors.primary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Not Satisfied'),
                      Text('Very Satisfied'),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitSurvey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('Submit Survey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
