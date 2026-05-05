import 'package:blog_app/services/api_config.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio();

  Future<Response?> login(String username, String password) async {
    try {
      return await dio.post(
        '${ApiConfig.baseUrl}/authenticate',
        data: {'name': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> getInfo(String? token) async {
    try {
      return await dio.get(
        '${ApiConfig.baseUrl}/getinfo',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> register(String username, String password) async {
    try {
      return await dio.post(
        '${ApiConfig.baseUrl}/adduser',
        data: {'name': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }
}
