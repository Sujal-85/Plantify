import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MongoService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator/web
  static const String baseUrl = 'http://192.168.1.70:3000/api';

  // --- Users ---
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
            'name': userData['name'],
            'email': userData['email'],
            'phone': userData['phoneNumber'], 
            'role': userData['role'],
            'profileImage': userData['profileImage'],
            // Add other mappings as needed
            'uid': userData['uid'] // Pass UID if backend handles it (our backend currently uses email as key mostly, but we can adapt)
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
          debugPrint("Failed to save user: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error saving user to Backend: $e");
    }
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    // Current backend route gets by email. If we only have UID here, we might need a UID route.
    // However, login flow usually has email. 
    // For now, let's assume we fetch by email if possible, or we need to update backend to support UID lookup.
    // The previous code passed UID. Let's add a TODO or try to fetch by email if we can refactor.
    // Ideally, backend /users/:email. 
    return null; // Placeholder until we align User ID vs Email lookup
  }
  
  // --- Scan Results ---
  Future<void> saveScanResult(Map<String, dynamic> scanData) async {
     try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan-results'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(scanData),
      );
       if (response.statusCode != 200 && response.statusCode != 201) {
          debugPrint("Failed to save scan: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error saving scan to Backend: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getUserScanResults(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scan-results/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Error fetching scans: $e");
    }
    return [];
  }

  // --- AI Diagnosis & Identification (Backend Proxy) ---
  Future<Map<String, dynamic>> diagnosePlant(String imagePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ai/diagnose'));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint("AI Diagnosis failed: ${response.body}");
        return {'error': 'Diagnosis failed on server'};
      }
    } catch (e) {
      debugPrint("Error calling AI Diagnose: $e");
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> identifyPlant(String imagePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ai/identify'));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint("AI Identification failed: ${response.body}");
        return {'error': 'Identification failed on server'};
      }
    } catch (e) {
      debugPrint("Error calling AI Identify: $e");
      return {'error': e.toString()};
    }
  }

  Future<String> getChatResponse(String message, List<Map<String, dynamic>> history) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message, 'history': history}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text'] ?? 'No response content';
      }
      return 'Server error: ${response.statusCode}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> generatePlantArticle(String plantName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/article'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'plantName': plantName}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text'] ?? 'Failed to generate article.';
      }
      return 'Server error: ${response.statusCode}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  void close() {
    // No-op for HTTP service
  }
}
