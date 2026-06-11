import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/models/post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentPostScreen extends StatefulWidget {
  const RecentPostScreen({super.key});

  @override
  State<RecentPostScreen> createState() => _RecentPostScreenState();
}

class _RecentPostScreenState extends State<RecentPostScreen> {
  late final TextEditingController _searchController;
  String _selectedSort = 'Recent';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Fetch latest posts when screen mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().getAllPost();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final allPosts = postProvider.posts;
    final isLoading = postProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B3558), size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Recent Content',
          style: TextStyle(
            color: Color(0xFF0B3558),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF0B3558), size: 26),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00365C)))
          : Column(
              children: [
                /// FILTER & SORT UTILITY BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF5F5F5F), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Search content',
                                  hintStyle: TextStyle(color: Color(0xFF9096A0), fontSize: 14),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  context.read<PostProvider>().search(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() => _selectedSort = value);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sort by: $_selectedSort',
                              style: const TextStyle(
                                color: Color(0xFF0B3558),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0B3558), size: 18),
                          ],
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'Recent', child: Text('Recent')),
                          const PopupMenuItem(value: 'Oldest', child: Text('Oldest')),
                        ],
                      ),
                    ],
                  ),
                ),

                /// UNIFIED CONTENT FEED LIST
                Expanded(
                  child: _buildPostList(allPosts),
                ),
              ],
            ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No content found',
          style: TextStyle(color: Color(0xFF9096A0), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 140),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final post = posts[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1C),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5F5F5F),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(Icons.history_rounded, size: 13, color: Color(0xFF9096A0)),
                        SizedBox(width: 5),
                        Text(
                          'PUBLISHED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9096A0),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFFEAEAEA),
                    child: const Icon(Icons.image_not_supported_outlined, size: 18, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}