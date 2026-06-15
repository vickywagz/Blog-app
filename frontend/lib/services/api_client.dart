import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiClient {
  // A single shared instance accessible across the whole app
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // 🔑 THE SECURE GATEWAY INTERCEPTOR
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read token from storage automatically on every outgoing call
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Centrally handle token expirations (e.g., 401 unauth re-routing)
          return handler.next(e);
        },
      ),
    );
  }
}