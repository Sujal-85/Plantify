import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';
import 'package:plant_analysis/core/services/community_service.dart';
import 'package:plant_analysis/features/community/models/community_post.dart';
import 'package:plant_analysis/features/community/screens/ask_community_screen.dart';
import 'package:plant_analysis/features/community/screens/community_post_detail_screen.dart';
import 'package:plant_analysis/widgets/glass_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plant_analysis/features/home/screens/dashboard_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _service = CommunityService();
  late Future<List<CommunityPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _service.getPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _service.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
             if (Navigator.canPop(context)) {
                Navigator.pop(context);
             } else {
                DashboardScreenState.updateIndex(context, 0);
             }
          },
        ),
        title: Text(l10n.community, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<CommunityPost>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(l10n.noPosts));
            }

            final posts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(posts[index]);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AskCommunityScreen()),
          );
          if (result == true) {
            _refreshPosts();
          }
        },
        label: Text(l10n.askCommunity),
        icon: const Icon(Icons.edit),
        backgroundColor: const Color(0xFF0056D2),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CommunityPostDetailScreen(post: post)));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.image != null && post.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: post.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(height: 200, color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[300],
                        child: Text(post.authorName[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('• ${post.authorLocation}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const Spacer(),
                      Text(timeago.format(post.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                   Text(
                    post.description, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[800])
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...post.tags.map((tag) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: Text('#$tag', style: TextStyle(color: Colors.blue[800], fontSize: 12)),
                      )),
                      const Spacer(),
                      const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${post.comments.length} ${l10n.answers}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
