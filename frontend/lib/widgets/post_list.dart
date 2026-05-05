import 'package:blog_app/models/post.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/widgets/post_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: context.watch<PostProvider>().searchKey.isEmpty
          ? context.watch<PostProvider>().getAllPost()
          : context.watch<PostProvider>().searchPost(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No journal entries yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(
            top: 6,
            bottom: 120,
          ),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 26),
          itemBuilder: (_, i) => PostCardWidget(
            post: snapshot.data![i],
          ),
        );
      },
    );
  }
}