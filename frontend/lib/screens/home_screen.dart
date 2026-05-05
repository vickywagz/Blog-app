import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/screens/add_update_screen.dart';
import 'package:blog_app/widgets/post_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _search = TextEditingController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: context.read<PostProvider>().isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'THE CURATOR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: Color(0xFF0B3558),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            size: 20,
                            color: Color(0xFF0B3558),
                          ),
                          onPressed: () {
                            context.read<PostProvider>().refresh();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 20,
                            color: Color(0xFF0B3558),
                          ),
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// SEARCH FIELD
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _search,
                    cursorColor: Colors.black87,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      hintText: 'Search the journal...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () {
                          context
                              .read<PostProvider>()
                              .search(_search.text);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// POSTS
                Expanded(
                  child: PostList(),
                ),
              ],
            ),
          ),
        ),

        /// FLOATING BUTTON
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF005A8D),
          elevation: 3,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddUpdateScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
