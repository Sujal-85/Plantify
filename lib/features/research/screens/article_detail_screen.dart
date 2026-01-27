import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/mongo_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String plantName;
  final String? initialContent;

  const ArticleDetailScreen({
    super.key,
    required this.plantName,
    this.initialContent,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late String _content;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _content = widget.initialContent ?? 'Loading original content...';
    if (widget.initialContent == null) {
      _loadOriginalContent();
    }
  }

  void _loadOriginalContent() {
    // Simulate loading original content
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _content = 'Succulents, the darlings of the plant world, are not just beautiful---they\'re also resilient and easy to care for. Here are quick tips to unlock their secrets and keep them thriving:';
        });
      }
    });
  }

  Future<void> _generateDeepResearch() async {
    setState(() => _isGenerating = true);
    final startTime = DateTime.now();
    
    final mongoService = context.read<MongoService>();
    final research = await mongoService.generatePlantArticle(widget.plantName);
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inMilliseconds;
    debugPrint('Research generated in ${duration}ms');

    if (mounted) {
      setState(() {
        _content = research;
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Article',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
              IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.black), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.eco, size: 100, color: AppColors.primary),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock the Secrets of ${widget.plantName}: Care Tips for Thriving Beauties',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Deep Research',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _isGenerating,
                        onChanged: (value) {
                          if (value) _generateDeepResearch();
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isGenerating)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else
                    SelectableText(
                      _content,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withValues(alpha: 0.7),
                        height: 1.6,
                      ),
                    ),
                  const SizedBox(height: 40),
                  const Text(
                    'Was this helpful?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFeedbackButton('Yes'),
                      const SizedBox(width: 12),
                      _buildFeedbackButton('No'),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}
