import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/widgets/post_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final posts = postProvider.posts;
    final isLoading = postProvider.isLoading;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00365C)),
      );
    }

    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Center(
            child: Text(
              'No journal entries yet',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF9096A0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(
        top: 6,
        // 🟢 FIXED: Increased padding so the last post cleanly clears the persistent floating nav bar layout shell
        bottom: 140,
      ),
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 26),
      itemBuilder: (context, i) {
        final currentPost = posts[i];

        return GestureDetector(
          onTap: () {
            context.go('/feed/post/${currentPost.id}');
          },
          child: PostCardWidget(post: currentPost),
        );
      },
    );
  }
}
