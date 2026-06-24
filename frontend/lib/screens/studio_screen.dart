import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/providers/auth_provider.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get logged-in user details safely
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.user?.id ?? '';
    final currentUserImage = authProvider.user?.profileImage ?? '';

    // 2. Watch your central PostProvider cache collection
    final postProvider = context.watch<PostProvider>();

    // 🟢 FILTER: Extract only posts where authorId matches the current user
    final authorPosts = postProvider.posts.where((post) {
      return post.authorId == currentUserId;
    }).toList();

    // 🟢 AGGREGATE METRICS: Compute values dynamically from your real dataset
    final int totalReads = authorPosts.fold(0, (sum, post) => sum + (post.viewsCount ?? 0));
    final int totalLikes = authorPosts.fold(0, (sum, post) => sum + post.likes.length);
    final int publishedCount = authorPosts.length; // Fallback assuming all items in feed collection are published

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'The Curator',
          style: TextStyle(
            color: Color(0xFF00365C),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.push("/profile-screen");
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: currentUserImage.isNotEmpty
                    ? NetworkImage(currentUserImage)
                    : const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256'),
                backgroundColor: const Color(0xFFEAEAEA),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// HEADER BLOCK
              const Text(
                'Creative Studio',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2328),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Manage your editorial presence and track\nyour narrative's reach.",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF7A8087),
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 28),

              /// ANALYTICS METRIC CARDS (Fed with dynamic real variables)
              _buildWideMetricCard('Total Reads', totalReads.toString(), true),
              const SizedBox(height: 16),
              _buildWideMetricCard('Total Likes', totalLikes.toString(), true),
              const SizedBox(height: 16),
              _buildWideMetricCard('Published Posts', publishedCount.toString(), false),

              const SizedBox(height: 36),

              /// RECENT CONTENT TITLE BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Content',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2328),
                      letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push("/recent-posts");
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF005A8D),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// RECENT CONTENT LIST DECK
          authorPosts.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text(
                    "You haven't published any articles yet.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: authorPosts.length > 5 ? 5 : authorPosts.length, // Limit layout overview block safely to top 5 items
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120), 
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = authorPosts[index];

                    return InkWell(
                      onTap: () {
                        context.go('/feed/post/${item.id}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F7), 
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // Fallback category text if your structure uses generic labels
                                    'ARTICLE LOG',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF00365C),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title ?? 'Untitled narrative',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2328),
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      /// Status Pill Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD6EADA),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Published',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E5A2A),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${item.viewsCount ?? 0} views',
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
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Color(0xFF1F2328),
                              ),
                              onPressed: () {
                                // Can be hooked up to link directly to your delete/update sheets
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// REFACTORED WORKSPACE COMPONENT FOR WIDE METRICS
  Widget _buildWideMetricCard(String title, String value, bool showGraphIcon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF7A8087),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00365C),
                  letterSpacing: -0.5,
                ),
              ),
              if (showGraphIcon) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF005A8D),
                  size: 22,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}