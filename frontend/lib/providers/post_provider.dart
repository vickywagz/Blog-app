import 'package:blog_app/models/post.dart';
import 'package:blog_app/services/post_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show Colors, ChangeNotifier;
import 'package:fluttertoast/fluttertoast.dart';

class PostProvider with ChangeNotifier {
  // --- INTERNAL STATE CORNER ---
  List<Post> _posts = [];
  bool _isLoading = false;
  String _searchKey = '';
  String _currentSort = 'recent'; // 🟢 Added: Tracks active filter type

  // --- GETTERS ---
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String get searchKey => _searchKey;
  String get currentSort =>
      _currentSort; // 🟢 Added: Exposes filter key to the UI

  /// Fetch all posts and cache them in memory reactively with explicit query sorts
  Future<void> getAllPost({String sortBy = 'recent'}) async {
    _isLoading = true;
    _currentSort = sortBy; // 🟢 Sync local tracking assignment

    // Delay notification slightly if this is run inside initState transitions
    Future.microtask(() => notifyListeners());

    try {
      print('GetAll Executed with filter parameter: $sortBy');

      // 🟢 CRITICAL: We pass the sorting string directly downstream to your Service interface
      Response? res = await PostService().getAllPost(sortBy: _currentSort);
      if (res != null && res.data != null) {
        _posts = (res.data as List).map((data) => Post.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error fetching posts: $e');
      _showToast('Failed to load journal entries', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update search string tracker and execute the remote endpoint call automatically
  void search(String query) {
    _searchKey = query;
    if (_searchKey.trim().isEmpty) {
      getAllPost(
        sortBy: _currentSort,
      ); // 🟢 Preserves active sort choice on search clear
    } else {
      searchPost();
    }
  }

  /// Query backend database based on explicit keyword filter
  Future<void> searchPost() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Search Executed for: $_searchKey');
      Response? res = await PostService().searchPost(_searchKey);
      if (res != null && res.data != null) {
        _posts = (res.data as List).map((data) => Post.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error matching query inputs: $e');
      _showToast('Search query request failed', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Wipe a specific narrative post log entry completely
  Future<void> deletePost(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? res = await PostService().deletePost(id);
      _showToast(res?.data['msg'] ?? 'Post deleted successfully');

      // OPTIMIZATION: Instantly drop the item locally instead of forcing an unnecessary extra network request
      _posts.removeWhere((element) => element.id == id);
    } catch (e) {
      _showToast('Failed to delete post record', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fresh clean reset of the search and feed stack pipeline
  Future<void> refresh() async {
    _searchKey = '';
    await getAllPost(
      sortBy: _currentSort,
    ); // 🟢 Pull fresh data matching current view option
  }

  /// Publish a new article node to the main hub architecture
  Future<void> createPost(
    String title,
    String body,
    String author,
    String authorId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? res = await PostService().createPost(
        title,
        body,
        author,
        authorId,
      );
      _showToast(res?.data['msg'] ?? 'Article published!');

      // Refresh local cache listing to seamlessly reflect new data entries
      await getAllPost(sortBy: _currentSort);
    } catch (e) {
      _showToast('Failed to publish entry', isError: true);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Patch modification details onto an active model log
  Future<void> updatePost(Post post) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? res = await PostService().updatePost(post);
      _showToast(res?.data['msg'] ?? 'Article details updated!');

      // OPTIMIZATION: Mutate the memory reference list directly instead of running full network resets!
      final index = _posts.indexWhere((element) => element.id == post.id);
      if (index != -1) {
        _posts[index] = post;
      } else {
        await getAllPost(sortBy: _currentSort);
      }
    } catch (e) {
      print('Error updating local state assignment: $e');
      _showToast('Failed to update article details', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementPostView(String id) async {
    try {
      // 1. Fire asynchronous background network pipeline node
      Response? res = await PostService().incrementView(id);

      // 2. OPTIMIZATION: Match with your correct viewsCount model key
      final index = _posts.indexWhere((element) => element.id == id);
      if (index != -1) {
        final currentViews =
            _posts[index].viewsCount; // 🟢 Updated to match your model
        _posts[index] = _posts[index].copyWith(
          viewsCount: currentViews + 1,
        ); // 🟢 Updated to match your model

        notifyListeners(); // Smoothly repaint active tracking numbers onto watching widgets
      }
    } catch (e) {
      print(
        'Error processing background view analytics routing incrementation: $e',
      );
    }
  }

  /// Simplified, unified feedback notification messenger toast helper
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// 🟢 Fetches a single post. Returns from local memory cache first, or falls back to API.
  Future<Post?> getSinglePost(String id) async {
    // Optimization: Check if we already have it loaded in memory
    final localMatch = _posts.firstWhere((element) => element.id == id, orElse: () => Post(id: '', title: '', body: '', author: '', authorId: '', postImage: '', viewsCount: 0, likes: [], savedBy: []));
    if (localMatch.id.isNotEmpty) return localMatch;

    try {
      Response? res = await PostService().getPostById(id);
      if (res != null && res.data != null) {
        return Post.fromJson(res.data);
      }
    } catch (e) {
      print('Error loading specific post ID node: $e');
    }
    return null;
  }

  /// 🟢 Fetches isolated list history for a targeted profile timeline view
  Future<List<Post>> fetchAuthorTimeline(String authorId) async {
    try {
      Response? res = await PostService().getPostsByAuthor(authorId);
      if (res != null && res.data != null) {
        return (res.data as List).map((data) => Post.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error tracking author timeline inputs: $e');
    }
    return [];
  }

  /// 🟢 Optimistically toggles a post like state
  Future<void> togglePostLike(String postId, String userId) async {
    final index = _posts.indexWhere((element) => element.id == postId);
    if (index == -1) return;

    final originalPost = _posts[index];
    List<String> updatedLikes = List.from(originalPost.likes);

    // Instant local mutation
    if (updatedLikes.contains(userId)) {
      updatedLikes.remove(userId);
    } else {
      updatedLikes.add(userId);
    }

    _posts[index] = originalPost.copyWith(likes: updatedLikes);
    notifyListeners(); // UI updates immediately!

    // Background server sync
    Response? res = await PostService().toggleLike(postId);
    
    // If server fails or returns an explicit bad code, gracefully roll back local state
    if (res == null || res.statusCode != 200) {
      print('Like sync failed. Rolling back state.');
      final rollBackIndex = _posts.indexWhere((element) => element.id == postId);
      if (rollBackIndex != -1) {
        _posts[rollBackIndex] = originalPost;
        notifyListeners();
      }
    }
  }

  /// 🟢 Optimistically toggles a post save/bookmark state
  Future<void> togglePostSave(String postId, String userId) async {
    final index = _posts.indexWhere((element) => element.id == postId);
    if (index == -1) return;

    final originalPost = _posts[index];
    List<String> updatedSavedBy = List.from(originalPost.savedBy);

    // Instant local mutation
    if (updatedSavedBy.contains(userId)) {
      updatedSavedBy.remove(userId);
    } else {
      updatedSavedBy.add(userId);
    }

    _posts[index] = originalPost.copyWith(savedBy: updatedSavedBy);
    notifyListeners(); // UI updates immediately!

    // Background server sync
    Response? res = await PostService().toggleBookmark(postId);
    
    if (res == null || res.statusCode != 200) {
      print('Bookmark sync failed. Rolling back state.');
      final rollBackIndex = _posts.indexWhere((element) => element.id == postId);
      if (rollBackIndex != -1) {
        _posts[rollBackIndex] = originalPost;
        notifyListeners();
      }
    }
  }
}
