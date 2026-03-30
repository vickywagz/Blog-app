import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio();
  static const String baseUrl = 'http://192.168.18.8:5000';

  Future<Response?> login(String username, String password) async {
    try {
      return await dio.post(
        '$baseUrl/authenticate',
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
        '$baseUrl/getinfo',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> register(String username, String password) async {
    try {
      return await dio.post(
        '$baseUrl/adduser',
        data: {'name': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }
}