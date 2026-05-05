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
    final username = context.read<AuthProvider>().user!.username;

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEAEAEA),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            post.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),

          const SizedBox(height: 14),

          /// BODY
          Text(
            post.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF5F5F5F),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 18),

          /// BOTTOM ROW
          Row(
            children: [
              /// AUTHOR
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'By ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: post.author,
                        style: const TextStyle(
                          color: Color(0xFF0B5E8E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ACTIONS
              if (username == post.author) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddUpdateScreen(post: post),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(width: 22),

                GestureDetector(
                  onTap: () async {
                    await context
                        .read<PostProvider>()
                        .deletePost(post.id);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD64545),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}