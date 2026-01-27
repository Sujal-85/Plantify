import 'package:flutter/material.dart';
import 'package:plant_analysis/core/services/community_service.dart';
import 'package:plant_analysis/features/community/models/community_post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPost post;
  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSending = false;
  late CommunityPost _localPost;

  @override
  void initState() {
    super.initState();
    _localPost = widget.post;
  }

  Future<void> _sendAnswer() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSending = true);
    
    final success = await CommunityService().addComment(_localPost.id, _commentController.text);
    if (success) {
      // Refresh local post data - ideally reload from server, but here we append locally for speed check or just reload
      // For simplicity, I'll Mock append or just rebuild. 
      // Real refresh:
      // final refreshed = await CommunityService().getPost(id); 
      // Here just a snackbar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Answer posted!')));
      Navigator.pop(context); // Go back to refresh feed or logic to refresh this screen
    }
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_localPost.cropName)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Post content
                if (_localPost.image != null)
                 ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _localPost.image!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                     placeholder: (context, url) => Container(height: 250, color: Colors.grey[200]),
                     errorWidget: (context, url, error) => Container(height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                  ),
                 ),
                 const SizedBox(height: 16),
                 Text(_localPost.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Text(_localPost.description, style: const TextStyle(fontSize: 16)),
                 const Divider(height: 32),
                 Text('${_localPost.comments.length} Answers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                 const SizedBox(height: 16),
                 ..._localPost.comments.map((comment) => Container(
                   margin: const EdgeInsets.only(bottom: 16),
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.grey[50], 
                     borderRadius: BorderRadius.circular(12),
                     border: comment.isExpert ? Border.all(color: Colors.green) : null,
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                           if (comment.isExpert) ...[
                             const SizedBox(width: 4),
                             const Icon(Icons.verified, size: 14, color: Colors.green),
                           ],
                           const Spacer(),
                           Text(timeago.format(comment.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                         ],
                       ),
                       const SizedBox(height: 4),
                       Text(comment.text),
                     ],
                   ),
                 )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write your answer...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _sendAnswer,
                  icon: _isSending ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
