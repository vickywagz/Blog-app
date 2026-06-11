import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/widgets/post_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    context.read<PostProvider>().search(_search.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AbsorbPointer(
        absorbing: context.watch<PostProvider>().isLoading,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA), 
          body: SafeArea(
            // 🟢 FIXED: Turned off bottom inset safe zone tracking. 
            // This allows the scrollable list to fluidly pass behind your floating dashboard bar.
            bottom: false, 
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Color(0xFF0B3558),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          size: 24,
                          color: Color(0xFF0B3558),
                        ),
                        onPressed: () {
                          // TODO: Implement notification navigation route sheet presentation
                        },
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
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _triggerSearch(),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        suffixIcon: _search.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _search.clear();
                                  });
                                  context.read<PostProvider>().refresh();
                                },
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onPressed: _triggerSearch,
                              ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// POSTS LIST CONTAINER
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF00365C),
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        _search.clear();
                        await context.read<PostProvider>().refresh();
                      },
                      child: const PostList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}