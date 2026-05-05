import 'dart:convert';
import 'dart:io';

import 'package:blog_app/models/post.dart';
import 'package:blog_app/services/api_config.dart';
import 'package:dio/dio.dart';

class PostService {
  final Dio dio = Dio();

  Future<Response?> getAllPost() async {
    try {
      return await dio.get('${ApiConfig.baseUrl}/getallpost');
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Response?> searchPost(String searchKey) async {
    try {
      return await dio.get('${ApiConfig.baseUrl}/searchpost/$searchKey');
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Response?> deletePost(String id) async {
    try {
      return await dio.delete('${ApiConfig.baseUrl}/deletepost/$id');
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Response?> createPost(
    String title,
    String body,
    String author,
    String authorId,
  ) async {
    try {
      return await dio.post(
        '${ApiConfig.baseUrl}/addpost',
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode({
          'title': title,
          'body': body,
          'author': author,
          'author_id': authorId,
        }),
      );
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Response?> updatePost(Post post) async {
    try {
      return await dio.put(
        '${ApiConfig.baseUrl}/updatepost/${post.id}',
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode({
          'title': post.title,
          'body': post.body,
          'author': post.author,
          'author_id': post.authorId,
        }),
      );
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }
}
