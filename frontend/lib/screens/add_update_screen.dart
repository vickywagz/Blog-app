import 'package:blog_app/models/post.dart';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddUpdateScreen extends StatefulWidget {
  final Post? post;

  const AddUpdateScreen({super.key, this.post});

  @override
  State<AddUpdateScreen> createState() => _AddUpdateScreenState();
}

class _AddUpdateScreenState extends State<AddUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _title.text = widget.post!.title;
      _body.text = widget.post!.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = context.read<AuthProvider>().user!;
    String author = user.username!;
    String authorId = user.id!;

    final isLoading = context.watch<PostProvider>().isLoading;

    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Color(0xFF0B3558),
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Text(
                        'THECURATOR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B3558),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004B7A),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: GestureDetector(
                          onTap: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (widget.post == null) {
                                      await context
                                          .read<PostProvider>()
                                          .createPost(
                                            _title.text,
                                            _body.text,
                                            author,
                                            authorId,
                                          );
                                    } else {
                                      // 🟢 FIXED: We pass the existing generated image string forward 
                                      // so it preserves consistency during a text modification save.
                                      Post updatedPost = Post(
                                        id: widget.post!.id,
                                        authorId: widget.post!.authorId,
                                        author: widget.post!.author,
                                        body: _body.text,
                                        title: _title.text,
                                        createdAt: widget.post!.createdAt,
                                        image: widget.post!.image, 
                                      );

                                      await context
                                          .read<PostProvider>()
                                          .updatePost(updatedPost);
                                    }

                                    _title.clear();
                                    _body.clear();

                                    Navigator.pop(context);
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Publish',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E5E5),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      /// WATERMARK
                      Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'CURATOR',
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.withOpacity(0.05),
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      ),

                      /// CONTENT
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TAGS
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD8EAF8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'NEW JOURNAL ENTRY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF005A8D),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                const Text(
                                  'Drafting in Private',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 34),

                            /// TITLE
                            TextFormField(
                              controller: _title,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Post Title',
                                hintStyle: TextStyle(
                                  color: Color(0xFFD7D7D7),
                                  fontWeight: FontWeight.w700,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: (val) =>
                                  val!.isEmpty ? 'Title cannot be empty' : null,
                            ),

                            const SizedBox(height: 8),

                            /// BLUE LINE
                            Container(
                              height: 2,
                              width: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6BA3D6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// BODY
                            TextFormField(
                              controller: _body,
                              minLines: 14,
                              maxLines: null,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Write your thoughts...',
                                hintStyle: TextStyle(
                                  color: Color(0xFFD7D7D7),
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: (val) =>
                                  val!.isEmpty ? 'Body cannot be empty' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// BOTTOM BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F7),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFE6E6E6),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_bold, size: 18),
                          const SizedBox(width: 14),
                          const Icon(Icons.format_italic, size: 18),
                          const SizedBox(width: 14),
                          const Icon(Icons.link, size: 18),
                          const SizedBox(width: 14),
                          const Icon(Icons.format_list_bulleted, size: 18),

                          const Spacer(),

                          const Text(
                            'AUTOSAVED',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Container(
                            height: 6,
                            width: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 3,
                          width: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF005A8D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}