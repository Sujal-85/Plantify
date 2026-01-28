import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String? _apiKey;

  GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'] {
    if (_apiKey != null) {
      _model = GenerativeModel(
        model: 'gemini-3-flash-preview', // Using vision model for image analysis capability if needed later
        apiKey: _apiKey!,
      );
    }
  }

  bool get isAvailable => _apiKey != null && _apiKey!.isNotEmpty;

  /// Identifies if an error is retryable (like server overload)
  bool _isRetryable(dynamic e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('503') || 
           msg.contains('overloaded') || 
           msg.contains('unavailable') ||
           msg.contains('resource exhausted');
  }

  /// Retries an operation with exponential backoff
  Future<T> _retryOperation<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
    int retryCount = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (retryCount >= maxRetries || !_isRetryable(e)) {
          rethrow;
        }
        retryCount++;
        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(milliseconds: 1000 * (1 << (retryCount - 1))));
      }
    }
  }

  /// Generates a detailed diagnosis report based on the plant name and disease.
  Future<String> getDetailedDiagnosis({
    required String plantName,
    required String diseaseName,
    required double confidence,
  }) async {
    if (!isAvailable) {
      return "AI service is not configured. Please add GEMINI_API_KEY to your .env file.";
    }

    final prompt = '''
      You are an expert botanist and plant pathologist. 
      I have scanned a plant which appears to be "$plantName" (or generic plant) 
      and the initial diagnosis detected "$diseaseName" with ${(confidence * 100).toStringAsFixed(1)}% confidence.

      Please provide a concise but detailed report in markdown format:
      1. **Confirmation**: Briefly analyze if this diagnosis makes sense for a typical garden/farm context.
      2. **Symptoms**: What specific visual signs should I look for to confirm this?
      3. **Causes**: What environmental factors (humidity, pests, soil) cause this?
      4. **Treatment**: Give 3 distinct steps for organic or chemical treatment.
      5. **Prevention**: How to prevent this in the future?

      Keep the tone helpful, professional, and easy to understand for a home gardener or farmer.
      IMPORTANT: Use **bold** text to highlight key points and include friendly emojis 🌿 to make the report engaging.
    ''';

    final textModel = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: _apiKey!);
    
    try {
      final content = [Content.text(prompt)];
      final response = await _retryOperation(() => textModel.generateContent(content));
      return response.text ?? "Unable to generate analysis at this time.";
    } catch (e) {
      if (_isRetryable(e)) {
        return "The AI service is currently busy. Please try again in a moment.";
      }
      return "Error contacting AI service: $e";
    }
  }


  /// Chat with the AI assistant
  Future<String> chat(String message, List<Map<String, dynamic>> history) async {
    if (!isAvailable) {
      return "AI service is not configured. Please add GEMINI_API_KEY to your .env file.";
    }

    try {
      final chatSession = _model.startChat(
        history: history.map((h) {
          final role = h['role'] == 'user' ? 'user' : 'model';
          final text = h['parts'][0]['text'];
           return Content(role, [TextPart(text)]);
        }).toList(),
      );

      final response = await _retryOperation(() => chatSession.sendMessage(Content.text(message)));
      return response.text ?? "No response from AI.";
    } catch (e) {
      if (_isRetryable(e)) {
        return "I'm receiving too many requests right now. Please try again shortly.";
      }
      return "Error: $e";
    }
  }

  /// Identify a plant from an image
  Future<Map<String, dynamic>> identifyPlant(String imagePath) async {
    if (!isAvailable) {
      return {'error': 'AI configuration missing'};
    }

    try {
      final bytes = await File(imagePath).readAsBytes();
      final prompt = "Identify this plant used in agriculture/gardening. Return JSON with keys: name, scientificName, description, uses, indianName. For 'description' and 'uses', provide detailed Markdown content with **bold** highlights, bullet points, and friendly emojis 🌿🌻. If not a plant, return error.";
      
      final content = [
        Content.multi([
           TextPart(prompt),
           DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _retryOperation(() => _model.generateContent(content));
      final text = response.text;
      
      if (text == null) return {'error': 'No identification returned'};

      // Try to parse JSON from Markdown block or raw text
      try {
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonString = text.substring(jsonStart, jsonEnd + 1);
          final parsed = json.decode(jsonString);
          return {
            'name': parsed['name'] ?? 'Unknown Plant',
            'scientificName': parsed['scientificName'] ?? 'Unknown',
            'description': parsed['description'] ?? 'No description.',
            'uses': parsed['uses'] ?? 'N/A',
            'indianName': parsed['indianName'],
          };
        }
        // Fallback if no JSON structure found
        return {
          'name': 'Plant Result',
          'scientificName': 'Check description',
          'description': text,
          'uses': 'Information contained in description.',
        };
      } catch (e) {
        return {
          'name': 'AI Result',
          'scientificName': 'Manual Check',
          'description': text,
          'uses': 'Information contained in description.',
        };
      }
    } catch (e) {
       if (_isRetryable(e)) {
        return {'error': "Service overloaded. Please try again."};
      }
      return {'error': e.toString()};
    }
  }
}
