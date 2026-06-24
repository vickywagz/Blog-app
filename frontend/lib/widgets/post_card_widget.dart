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
    // 🟢 Extract the full user model so we can grab the ID for array lookups
    final currentUser = context.read<AuthProvider>().user;
    final currentUserId = currentUser?.id ?? '';
    final currentUserName = currentUser?.name;

    // 🟢 Check interaction flags dynamically based on your Post model lists
    final isLiked = post.likes.contains(currentUserId);
    final isSaved = post.savedBy.contains(currentUserId);

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

                const SizedBox(height: 12), // 🟢 Slightly adjusted to accommodate interactive hit targets cleanly

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
                          color: Color(0xFF00365C),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// 🟢 DYNAMIC LIKES TOGGLE BUTTON
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (currentUserId.isNotEmpty) {
                          context.read<PostProvider>().togglePostLike(post.id, currentUserId);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 16,
                              color: isLiked ? Colors.redAccent : const Color(0xFF9096A0),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likes.length}', // 🟢 Displays live total array length count
                              style: TextStyle(
                                color: isLiked ? Colors.redAccent : const Color(0xFF9096A0),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    /// 🟢 DYNAMIC BOOKMARK/SAVE TOGGLE BUTTON
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (currentUserId.isNotEmpty) {
                          context.read<PostProvider>().togglePostSave(post.id, currentUserId);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 16,
                          color: isSaved ? const Color(0xFF00365C) : const Color(0xFF9096A0),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    /// VIEWS STATISTIC
                    const Icon(
                      Icons.visibility_outlined,
                      size: 15,
                      color: Color(0xFF9096A0),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.5k', // Keeping view counter placeholder intact
                      style: TextStyle(
                        color: Color(0xFF9096A0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                   
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
                              Spacer(),
                              Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        if (currentUserName == post.author)
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
            child: post.postImage.isNotEmpty 
                ? Image.network(
                    post.postImage, 
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const _ImageFallback();
                    },
                  )
                : const _ImageFallback(), 
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      color: const Color(0xFFEAEAEA),
      child: const Icon(
        Icons.image_not_supported_outlined, 
        color: Colors.grey, 
        size: 20,
      ),
    );
  }
}