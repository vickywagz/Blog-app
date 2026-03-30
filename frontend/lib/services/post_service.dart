import 'dart:convert';
import 'dart:io';

import 'package:blog_app/models/post.dart';
import 'package:dio/dio.dart';

class PostService {
  final Dio dio = Dio();
  static const String baseUrl = 'http://192.168.18.8:5000';

  Future<Response?> getAllPost() async {
    try {
      return await dio.get('$baseUrl/getallpost');
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Response?> searchPost(String searchKey) async {
    try {
      return await dio.get('$baseUrl/searchpost/$searchKey');
    } on DioException catch (err) {
      return err.response;
    } catch (error, stacktrace) {
      throw Exception("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<Response?> deletePost(String id) async {
    try {
      return await dio.delete('$baseUrl/deletepost/$id');
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
        '$baseUrl/addpost',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
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
        '$baseUrl/updatepost/${post.id}',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
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