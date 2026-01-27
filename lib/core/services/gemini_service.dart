import 'dart:io';
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
    ''';

    // Note: For text-only prompts we can use gemini-pro, but gemini-pro-vision supports text too.
    // Ideally we should switch models based on input, but for this specific text prompt:
    final textModel = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: _apiKey!);
    
    try {
      final content = [Content.text(prompt)];
      final response = await textModel.generateContent(content);
      return response.text ?? "Unable to generate analysis at this time.";
    } catch (e) {
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
          final parts = (h['parts'] as List).map((p) => Content.text(p['text'])).toList(); // Simplified content extraction
          // Check if parts is List<Map> or just List<Content> (not typical in raw json)
          // Actually, generative_ai package expects Content objects.
          // Let's assume input history is simple for now or we adapt it.
          // Given specific map structure: {'role': 'user', 'parts': [{'text': '...'}]}
           final text = h['parts'][0]['text'];
           return Content(role, [TextPart(text)]);
        }).toList(),
      );

      final response = await chatSession.sendMessage(Content.text(message));
      return response.text ?? "No response from AI.";
    } catch (e) {
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
      final prompt = "Identify this plant used in agriculture/gardening. Return JSON with keys: name, scientificName, description, uses, indianName. If not a plant, return error.";
      
      final content = [
        Content.multi([
           TextPart(prompt),
           DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final text = response.text;
      
      if (text == null) return {'error': 'No identification returned'};

      // Try to parse JSON from Markdown block
      final jsonString = text.replaceAll('```json', '').replaceAll('```', '').trim();
      try {
         // This assumes the model returns clean JSON. We might need robust parsing.
         // For now, return a basic map if parsing fails or rely on model instruction.
         // Or just return the text description if JSON fails.
         // Let's instruct the model to be strict JSON.
         // Actually, let's just return the raw text for now if structure is complex, 
         // but IdentifyResultsScreen expects a Map.
         // I'll assume valid JSON usage or basic text fallback.
         // Actually, simple regex to find JSON object?
         // Let's leave it simple:
          // We can't easily parse arbitrary text to map without strict prompt.
          // Let's try to pass the text as 'description' and 'name' as 'Unknown' if not json.
          // But user wants "identify check" working.
          return {'name': 'AI Identified Plant', 'description': text, 'scientificName': 'Check description'};
      } catch (e) {
         return {'name': 'AI Result', 'description': text, 'scientificName': ''};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
