import 'package:dio/dio.dart';
import 'package:blog_app/models/post.dart';
import 'api_client.dart';

class PostService {
  // 🟢 Leverages the secure shared client instance
  final Dio _dio = ApiClient().dio;

  // 🟢 Update your method to accept the optional sortBy string parameter
  Future<Response?> getAllPost({String sortBy = 'recent'}) async {
    try {
      // Pass the sort value as a query parameter inside your Dio request configuration block
      final response = await _dio.get(
        '/getallpost',
        queryParameters: {
          'sort':
              sortBy, // 🟢 Matches your backend's expected query key (?sort=recent)
        },
      );

      return response;
    } catch (e) {
      print('Backend service layer fetch error: $e');
      return null;
    }
  }

  Future<Response?> searchPost(String searchKey) async {
    try {
      return await _dio.get('/searchpost/$searchKey');
    } on DioException catch (err) {
      return err.response;
    }
  }

  Future<Response?> deletePost(String id) async {
    try {
      // 🟢 The secure interceptor automatically injects token for deletion authorization
      return await _dio.delete('/deletepost/$id');
    } on DioException catch (err) {
      return err.response;
    }
  }

  Future<Response?> createPost(
    String title,
    String body,
    String author,
    String authorId,
  ) async {
    try {
      return await _dio.post(
        '/addpost',
        data: {
          'title': title,
          'body': body,
          'author': author,
          'author_id': authorId,
        },
      );
    } on DioException catch (err) {
      return err.response;
    }
  }

  Future<Response?> updatePost(Post post) async {
    try {
      return await _dio.put(
        '/updatepost/${post.id}',
        data: {
          'title': post.title,
          'body': post.body,
          'author': post.author,
          'author_id': post.authorId,
        },
      );
    } on DioException catch (err) {
      return err.response;
    }
  }

  /// 🟢 ADDED: Incremental View Trigger Node
  /// Fires a PATCH request to your incremental backend endpoint router
  Future<Response?> incrementView(String id) async {
    try {
      // Targets your specific endpoint: PATCH /post/:id/view
      return await _dio.patch('/post/$id/view');
    } on DioException catch (err) {
      // Gracefully catches network/server flags without breaking consumer streams
      print('Dio network exception handling incremental background view: ${err.message}');
      return err.response;
    }
  }

  /// 🟢 Fetch a singular post node by its database ID
  Future<Response?> getPostById(String id) async {
    try {
      // Maps to your standard item lookup endpoint pattern
      return await _dio.get('/getpost/$id'); 
    } on DioException catch (err) {
      return err.response;
    }
  }

  /// 🟢 Fetch all posts matching a specific author's ID
  Future<Response?> getPostsByAuthor(String authorId) async {
    try {
      // Maps to a parameterized endpoint structure
      return await _dio.get('/getpostsbyauthor/$authorId');
    } on DioException catch (err) {
      return err.response;
    }
  }

  /// 🟢 Dispatches a POST request to toggle like status
  Future<Response?> toggleLike(String postId) async {
    try {
      return await _dio.post('/post/$postId/like');
    } on DioException catch (err) {
      return err.response;
    }
  }

  /// 🟢 Dispatches a POST request to toggle bookmark/saved status
  Future<Response?> toggleBookmark(String postId) async {
    try {
      return await _dio.post('/post/$postId/save');
    } on DioException catch (err) {
      return err.response;
    }
  }
}