import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plant_analysis/features/community/models/community_post.dart';

class CommunityService {
  // Use 10.0.2.2 for Android Emulator, or localhost for iOS/Web if needed
  // If running on physical device, use your machine's local IP address (e.g. 192.168.1.x)
  static const String baseUrl = 'http://192.168.1.70:3000/api/posts'; 

  Future<List<CommunityPost>> getPosts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CommunityPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Connection failed: $e'); 
    }
  }

  Future<bool> createPost(String crop, String title, String description, String? imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'authorName': 'Me', // Dynamic user name later
          'cropName': crop,
          'title': title,
          'description': description,
          'image': imageBase64,
          'tags': [crop]
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  Future<bool> addComment(String postId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'authorName': 'Me', 
          'text': text,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }
}
