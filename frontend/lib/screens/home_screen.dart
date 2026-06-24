import 'dart:async'; // 🟢 Needed for Timer control mechanics
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/widgets/post_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _search;
  late final _Debouncer _debouncer; // 🟢 Local structural text debouncer

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    // Initialize with a 500ms safety valve window before striking backend endpoints
    _debouncer = _Debouncer(delay: const Duration(milliseconds: 500));

    // Initial fetch trigger on system startup pipeline landing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().getAllPost(sortBy: 'recent');
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _debouncer
        .dispose(); // Wipe background timers cleanly to protect memory lifecycle
    super.dispose();
  }

  void _triggerSearch() {
    context.read<PostProvider>().search(_search.text);
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AbsorbPointer(
        absorbing: postProvider.isLoading,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
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
                          context.push("/notification-screen");
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
                        setState(
                          () {},
                        ); // Repoints clear/arrow suffix UI items dynamically

                        _debouncer.run(() {
                          _triggerSearch();
                        });
                      },
                    ),
                  ),

                  // 🟢 REMOVED: The horizontal Filter Chips Row section has been deleted from here
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

/// 🟢 Lightweight Private Debouncer Utility Class
class _Debouncer {
  final Duration delay;
  Timer? _timer;

  _Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel(); // Terminate old timers immediately if user keeps typing
    _timer = Timer(
      delay,
      action,
    ); // Spawn clean request trigger window execution
  }

  void dispose() {
    _timer?.cancel();
  }
}
