import 'package:blog_app/models/post.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/screens/add_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostCardWidget extends StatelessWidget {
  final Post post;

  const PostCardWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user?.username;

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEAEAEA),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- LEFT SIDE: TEXT CONTENT & STATS METRICS ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1C1C),
                  ),
                ),

                const SizedBox(height: 8),

                /// BODY EXCERPT
                Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF6E7582),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 16),

                /// BOTTOM FOOTER: AUTHOR & STATS ROW
                Row(
                  children: [
                    /// AUTHOR LABEL
                    Flexible(
                      child: Text(
                        'By ${post.author}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF00365C), // Premium deep brand tone
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// LIKES STATISTIC
                    const Icon(
                      Icons.favorite_border_rounded,
                      size: 15,
                      color: Color(0xFF9096A0),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '1.2k', // Temporary design fallback placeholder match
                      style: TextStyle(
                        color: Color(0xFF9096A0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// VIEWS STATISTIC
                    const Icon(
                      Icons.visibility_outlined,
                      size: 15,
                      color: Color(0xFF9096A0),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.5k', // Temporary design fallback placeholder match
                      style: TextStyle(
                        color: Color(0xFF9096A0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 4),

                    /// THREE-DOTS POPUP MENU BUTTON
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Color(0xFF1F2328),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 110),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onSelected: (action) async {
                        if (action == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddUpdateScreen(post: post),
                            ),
                          );
                        } else if (action == 'delete') {
                          await context.read<PostProvider>().deletePost(post.id);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          height: 38,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: Colors.black87),
                              SizedBox(width: 8),
                              Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        // Only let authors wipe their own posts away
                        if (currentUser == post.author)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            height: 38,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFD64545)),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD64545),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          /// --- RIGHT SIDE: PREMIUM PRE-CACHED POST ROUNDED CORNER CARD IMAGE ---
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              post.image,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Smooth local fallback safety shape in case client device network connection drops out
                return Container(
                  width: 84,
                  height: 84,
                  color: const Color(0xFFEAEAEA),
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 20),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}