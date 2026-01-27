import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/tflite_service.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/database_service.dart';
import 'identify_results_screen.dart';
import 'identify_error_screen.dart';

class IdentifyProcessingScreen extends StatefulWidget {
  final String imagePath;
  const IdentifyProcessingScreen({super.key, required this.imagePath});

  @override
  State<IdentifyProcessingScreen> createState() => _IdentifyProcessingScreenState();
}

class _IdentifyProcessingScreenState extends State<IdentifyProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processIdentification();
  }

  Future<void> _processIdentification() async {


    if (!mounted) return;

    final tfliteService = context.read<TFLiteService>();
    final geminiService = context.read<GeminiService>();
    
    // Check Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    try {
      // Step 1: Offline Analysis (TFLite)
      final rawResult = await tfliteService.predict(widget.imagePath);
      final String rawLabel = rawResult['label'] ?? 'Unknown';
      final double confidence = rawResult['confidence'] ?? 0.0;
      
      // Extract Crop Name
      String cropName = rawLabel.split('___')[0]; 
      
      bool offlineIdentified = false;
      Map<String, dynamic>? resultData;

      if (confidence > 0.7 && rawLabel != 'Unknown' && rawLabel != 'Detection Failed') {
        // Look up in Encyclopedia
         resultData = await _lookupEncyclopedia(cropName);
         if (resultData != null) {
           offlineIdentified = true;
         }
      }

      // Step 2: Decision
      if (offlineIdentified) {
        _navigateToResults(resultData!);
      } else if (isOnline) {
        // Fallback to Backend AI (Now Local Gemini)
        final data = await geminiService.identifyPlant(widget.imagePath);
        if (!data.containsKey('error')) {
          _navigateToResults(data);
        } else {
          _navigateToError('AI Identification failed: ${data['error']}');
        }
      } else {
        _navigateToError('Plant not recognized offline. Connect to internet for AI identification.');
      }

    } catch (e) {
      _navigateToError(e.toString());
    }
  }

  Future<Map<String, dynamic>?> _lookupEncyclopedia(String cropName) async {
     try {
       final dbService = context.read<DatabaseService>();
       final plantData = await dbService.getPlant(cropName);
       
       if (plantData != null) {
         return {
           'name': plantData['name'],
           'scientificName': plantData['scientificName'] ?? 'Unknown',
           'description': plantData['description'] ?? 'No description.',
           'uses': plantData['uses'] ?? 'N/A',
           'indianName': plantData['indianName'],
         };
       }
     } catch (e) {
       debugPrint('Encyclopedia SQLite lookup failed: $e');
     }
     return null;
  }

  void _navigateToResults(Map<String, dynamic> data) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IdentifyResultsScreen(
          imagePath: widget.imagePath,
          plantData: data,
        ),
      ),
    );
  }

  void _navigateToError(String message) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IdentifyErrorScreen(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Identifying Plant...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
            const SizedBox(height: 8),
             const Text(
              'Checking local database & AI...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
