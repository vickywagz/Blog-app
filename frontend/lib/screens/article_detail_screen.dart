import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/post_provider.dart'; 
import 'package:blog_app/models/post.dart'; // Ensure correct path to your Post model

class ArticleDetailScreen extends StatefulWidget {
  final String postId; 

  const ArticleDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final ScrollController _scrollController;
  bool _hasTriggeredView = false; 

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose(); 
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) { 
      if (!_hasTriggeredView) {
        setState(() {
          _hasTriggeredView = true;
        });
        _incrementViewCount();
      }
    }
  }

  Future<void> _incrementViewCount() async {
    try {
      await context.read<PostProvider>().incrementPostView(widget.postId);
      print('🟢 Analytics Engine: Post view successfully recorded.');
    } catch (e) {
      print('🔴 Analytics Engine: Error tracking view event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Dynamic Query: Read current data array out of PostProvider
    final postProvider = context.watch<PostProvider>();
    
    // Locate the matching post ID within your provider's internal memory lists
    Post? post;
    try {
      post = postProvider.posts.firstWhere((p) => p.id == widget.postId);
    } catch (_) {
      // Fallback fallback edge case lookup inside secondary lists if any (e.g., trendings, recents)
      post = null;
    }

    // 🛑 Handle loading/missing state safely
    if (post == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(backgroundColor: const Color(0xFFF9FAFC), elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00365C)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), 
      
      /// 1. FIXED TOP APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2328), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'The Curator',
          style: TextStyle(
            color: Color(0xFF00365C),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              post.savedBy.contains(widget.postId) // Dynamic toggle color hint placeholder
                  ? Icons.bookmark_rounded 
                  : Icons.bookmark_border_rounded, 
              color: const Color(0xFF1F2328), 
              size: 22,
            ),
            onPressed: () {
              // Action logic goes here
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      /// 2. SCROLLABLE ARTICLE BODY
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController, 
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Dynamic Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E9F3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PERSPECTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00365C),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              /// 🟢 DYNAMIC: Article Headline Title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2328),
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              /// 🟢 DYNAMIC: Author Profile Row Panel
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFEAEAEA),
                    child: Icon(Icons.person_outline_rounded, size: 18, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'By ${post.author.isNotEmpty ? post.author : "Anonymous"}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2328),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Views: ${post.viewsCount}  •  ${_calculateReadTime(post.body)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A8087),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              /// 🟢 OPTIONAL DISPLAY: Post Image Cover Illustration
              if (post.postImage.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.postImage,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              /// 🟢 DYNAMIC: Main Body Narrative Block
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3.5,
                    height: 44, 
                    margin: const EdgeInsets.only(top: 4, right: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00365C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      post.body,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF2C3036),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// 3. INTERACTIVE FOOTER BLOCK
              Row(
                children: [
                  /// Reaction Pill Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up_outlined, size: 16, color: Color(0xFF2C3036)),
                        const SizedBox(width: 8),
                        Text(
                          '${post.likes.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3036),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Share Pill Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.share_outlined, size: 16, color: Color(0xFF2C3036)),
                        const SizedBox(width: 8),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3036),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              /// 🟢 DYNAMIC: Publication Timestamp Stamp
              if (post.createdAt != null)
                Text(
                  'Published on ${post.createdAt!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9096A0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper string generator calculating average reading runtime metrics
  String _calculateReadTime(String bodyText) {
    final wordCount = bodyText.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil(); // ~200 Words Per Minute
    return '$minutes min read';
  }
}