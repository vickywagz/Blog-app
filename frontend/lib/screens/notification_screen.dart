import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/notification_provider.dart';
import 'package:blog_app/models/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // 🟢 Request live notification feed metrics from /notifications when view mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  // Minimalist human-readable timestamp helper engine
  String _getRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  void _handleNotificationTap(NotificationModel item) {
    if (item.postId.isNotEmpty) {
      context.go('/feed/post/${item.postId}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target post could not be located.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3558)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0B3558),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => provider.markAllAsRead(),
            child: const Text(
              'Mark all as read',
              style: TextStyle(
                color: Color(0xFF0B3558),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00365C)))
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "You're all caught up!",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _buildNotificationCard(
                      item: item,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🟢 POPULATED AVATAR RENDERING ENGINE
                          _buildCircularAvatar(item),
                          const SizedBox(width: 12),

                          /// 🟢 RE-MAPPED TEXT LAYOUT SUB-SYSTEM
                          Expanded(
                            child: _buildContentByType(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildCircularAvatar(NotificationModel item) {
    if (item.type == 'trending') {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEAD9),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.trending_up_rounded, color: Color(0xFFE76F51), size: 20),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF1F3F5),
      backgroundImage: item.senderAvatar.isNotEmpty ? NetworkImage(item.senderAvatar) : null,
      child: item.senderAvatar.isEmpty
          ? Text(
              item.senderName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Color(0xFF0B3558), fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildContentByType(NotificationModel item) {
    final timeStr = _getRelativeTime(item.createdAt);

    if (item.type == 'like') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF1C1C1C), fontSize: 14, height: 1.3),
              children: [
                TextSpan(
                  text: '${item.senderName} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: 'liked your post '),
                TextSpan(
                  text: "'${item.postTitle}'",
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF5F5F5F)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      );
    }

    if (item.type == 'comment') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF1C1C1C), fontSize: 14, height: 1.3),
              children: [
                TextSpan(
                  text: '${item.senderName} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: 'commented on your post '),
                TextSpan(
                  text: "'${item.postTitle}'",
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF5F5F5F)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      );
    }

    // Default Fallback: Trending Activity layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF1C1C1C), fontSize: 14, height: 1.3),
            children: [
              const TextSpan(text: 'Your post '),
              TextSpan(
                text: "'${item.postTitle}'",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B3558)),
              ),
              const TextSpan(text: ' is trending!'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD8BE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'TRENDING',
                style: TextStyle(
                  color: Color(0xFFE76F51),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationCard({required NotificationModel item, required Widget child}) {
    final bool isUnread = !item.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleNotificationTap(item),
        borderRadius: BorderRadius.circular(12),
        // 🟢 FIXED: Wrapped inside explicit dynamic Material padding layer so ink drops don't glitch 
        child: Ink(
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF3F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isUnread ? null : Border.all(color: const Color(0xFFF1F3F5), width: 1),
            boxShadow: isUnread
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}