import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact post structures matching your premium mockup
    final recentContent = [
      {
        'category': 'TECH & CULTURE',
        'title': 'The Future of Minimal Computing',
        'status': 'Published',
        'time': 'Updated 2 days ago',
      },
      {
        'category': 'DESIGN',
        'title': 'Aesthetics of the Void',
        'status': 'Draft',
        'time': 'Last edit 4 hours ago',
      },
      {
        'category': 'PHILOSOPHY',
        'title': 'The Curator’s Manifesto',
        'status': 'Published',
        'time': 'Updated 1 week ago',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256',
                ),
                backgroundColor: const Color(0xFFEAEAEA),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
              'Manage your editorial presence and track\nyour narrative\'s reach.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF7A8087),
                height: 1.3,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 28),

            /// ANALYTICS METRIC CARDS (Full-width cards matching screen.png)
            _buildWideMetricCard('Total Reads', '1,240', true),
            const SizedBox(height: 16),
            _buildWideMetricCard('Total Likes', '842', true),
            const SizedBox(height: 16),
            _buildWideMetricCard('Published Posts', '12', false),

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
                    context.push("/Recent-Post-Screen");
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
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              itemCount: recentContent.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 120,
              ), // Padding to prevent navigation capsule collision
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = recentContent[index];
                final bool isPublished = item['status'] == 'Published';

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF1F3F7,
                    ), // Soft grayish container fill matching mockup
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
                              item['category']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00365C),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['title']!,
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
                                    color: isPublished
                                        ? const Color(0xFFD6EADA)
                                        : const Color(0xFFE2E5ED),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['status']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isPublished
                                          ? const Color(0xFF1E5A2A)
                                          : const Color(0xFF495057),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item['time']!,
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
                          // Trigger edit context bottom sheet operations
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
