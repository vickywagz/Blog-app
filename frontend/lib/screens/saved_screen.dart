import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/providers/auth_provider.dart'; // 🟢 Added to get active User ID

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fetch current User ID to check against the 'savedBy' collection array
    final authProvider = context.watch<AuthProvider>();
    final String currentUserId = authProvider.user?.id ?? '';

    // 2. Watch live post data from your PostProvider
    final postProvider = context.watch<PostProvider>();

    // 🟢 FILTER: Find all articles where the savedBy array contains our logged-in User ID
    final savedArticles = postProvider.posts.where((post) {
      return post.savedBy.contains(currentUserId);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'THE CURATOR',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Color(0xFF1F2328),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF1F2328)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /// TITLE BLOCKS
            const Text(
              'Saved Articles',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2328),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${savedArticles.length} articles saved',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF7A8087),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            /// VERTICAL COMPACT INTERIOR DECK
            Expanded(
              child: savedArticles.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No bookmarked entries found.',
                            style: TextStyle(
                              color: Color(0xFF7A8087),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: savedArticles.length,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final article = savedArticles[index];

                        return InkWell(
                          onTap: () {
                            // Navigates cleanly to your post details page view
                            context.go('/feed/post/${article.id}');
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// Article Image Thumbnail Frame
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAEAEA),
                                  borderRadius: BorderRadius.circular(16),
                                  image:
                                      article.postImage != null &&
                                          article.postImage!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            article.postImage!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child:
                                    article.postImage == null ||
                                        article.postImage!.isEmpty
                                    ? const Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),

                              /// Mid Deck Meta Details Text Panel
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      article.title ?? 'Untitled',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2328),
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      article.author ?? 'Unknown Author',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7A8087),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              /// Dynamic Save Context Trigger Icon
                              IconButton(
                                icon: const Icon(
                                  Icons.bookmark_rounded,
                                  color: Color(0xFF005A8D),
                                  size: 24,
                                ),
                                onPressed: () {
                                  // 🟢 CONNECTED: Call your exact optimistic toggle bookmark function
                                  context.read<PostProvider>().togglePostSave(
                                    article.id,
                                    currentUserId,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
