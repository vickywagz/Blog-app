import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/models/post.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RecentPostScreen extends StatefulWidget {
  const RecentPostScreen({super.key});

  @override
  State<RecentPostScreen> createState() => _RecentPostScreenState();
}

class _RecentPostScreenState extends State<RecentPostScreen> {
  late final TextEditingController _searchController;
  String _selectedSort = 'Recent';
  String _searchQuery = ''; 

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Fetch latest global posts collection when screen mounts
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
    final authProvider = context.watch<AuthProvider>();
    
    final currentUserId = authProvider.user?.id ?? '';
    final isLoading = postProvider.isLoading;

    // 🟢 Step 1: Filter down list so it ONLY contains the logged-in user's posts matching authorId
    List<Post> userPosts = postProvider.posts.where((post) {
      return post.authorId == currentUserId; 
    }).toList();

    // 🟢 Step 2: Apply real-time local search query filtering
    if (_searchQuery.isNotEmpty) {
      userPosts = userPosts.where((post) {
        return post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               post.body.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 🟢 Step 3: Apply Sorting Rules using the actual model createdAt DateTime values
    if (_selectedSort == 'Recent') {
      userPosts.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!); // Newest first
      });
    } else if (_selectedSort == 'Oldest') {
      userPosts.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!); // Oldest first
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B3558), size: 20),
          onPressed: () => context.pop(), 
        ),
        title: const Text(
          'My Recent Content',
          style: TextStyle(
            color: Color(0xFF0B3558),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
                                  hintText: 'Search my content',
                                  hintStyle: TextStyle(color: Color(0xFF9096A0), fontSize: 14),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
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
                  child: _buildPostList(userPosts),
                ),
              ],
            ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No personal content found.',
          style: TextStyle(color: Color(0xFF9096A0), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 40),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final post = posts[index];

        return InkWell(
          onTap: () {
            context.go('/feed/post/${post.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, size: 13, color: Color(0xFF9096A0)),
                          const SizedBox(width: 5),
                          Text(
                            'VIEWS: ${post.viewsCount}', 
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9096A0),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.history_rounded, size: 13, color: Color(0xFF9096A0)),
                          const SizedBox(width: 5),
                          const Text(
                            'MY POST',
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
                    post.postImage, // 🟢 FIXED: Changed post.image to post.postImage
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
          ),
        );
      },
    );
  }
}