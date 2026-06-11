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

  // --- GETTERS ---
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String get searchKey => _searchKey;

  /// Fetch all posts and cache them in memory reactively
  Future<void> getAllPost() async {
    _isLoading = true;
    // Delay notification slightly if this is run inside initState transitions
    Future.microtask(() => notifyListeners());

    try {
      print('GetAll Executed');
      Response? res = await PostService().getAllPost();
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
      getAllPost();
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
    await getAllPost();
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
      await getAllPost();
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

      // 🟢 OPTIMIZATION: Mutate the memory reference list directly instead of running full network resets!
      // This preserves our local fallback image configuration string flawlessly.
      final index = _posts.indexWhere((element) => element.id == post.id);
      if (index != -1) {
        _posts[index] = post;
      } else {
        // Fallback safety catch
        await getAllPost();
      }
    } catch (e) {
      print('Error updating local state assignment: $e');
      _showToast('Failed to update article details', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
