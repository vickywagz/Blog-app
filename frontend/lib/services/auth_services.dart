import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  // 🟢 Hook directly into the secure gateway client
  final Dio _dio = ApiClient().dio;

  Future<Response?> login(String email, String password) async {
    print('🌐 [AuthService] Initiating post request to /authenticate...');
    print('📦 [AuthService] Payload data: {email: $email}');

    try {
      final response = await _dio.post(
        '/authenticate', // 🟢 CHANGED: Reverting back to your active backend route name
        data: {
          'email': email, // Keep sending email!
          'password': password,
        },
        options: Options(
          validateStatus: (status) {
            print(
              '🚦 [AuthService] Login Server responded with HTTP Status Code: $status',
            );
            // Accept 404 inside validateStatus as well so it returns cleanly
            return status == 200 ||
                status == 400 ||
                status == 401 ||
                status == 404 ||
                status == 500;
          },
        ),
      );

      print('✅ [AuthService] Login network request finished cleanly.');
      return response;
    } on DioException catch (ex) {
      print('❌ [AuthService] DioException caught: ${ex.message}');
      return ex.response;
    } catch (e) {
      print(
        '💥 [AuthService] Unexpected code runtime error inside login call: $e',
      );
      return null;
    }
  }

  Future<Response?> getInfo() async {
    print('🌐 [AuthService] Fetching profile data from /getinfo...');
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      if (token == null) {
        print('⚠️ [AuthService] No token found in secure storage.');
        return null;
      }

      print('🔑 [AuthService] Raw token value from storage: $token');

      // 🟢 FORMAT SANITIZATION GUARD:
      // If the token already contains the word "Bearer", use it directly.
      // If it does NOT contain "Bearer", explicitly prepend it.
      final String authorizationHeaderValue = token.startsWith('Bearer ')
          ? token
          : 'Bearer $token';

      print(
        '🚀 [AuthService] Exact outgoing Authorization Header: "$authorizationHeaderValue"',
      );

      return await _dio.get(
        '/getinfo',
        options: Options(
          headers: {'Authorization': authorizationHeaderValue},
          validateStatus: (status) =>
              status == 200 || status == 401 || status == 500,
        ),
      );
    } on DioException catch (ex) {
      print(
        '❌ [AuthService] DioException caught during getInfo call: ${ex.message}',
      );
      return ex.response;
    } catch (e) {
      print('💥 [AuthService] Unexpected error: $e');
      return null;
    }
  }

  Future<Response?> register(String name, String email, String password) async {
    print('🌐 [AuthService] Initiating post request to /register...');
    print('📦 [AuthService] Payload data: {name: $name, email: $email}');

    try {
      final response = await _dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
        options: Options(
          validateStatus: (status) {
            print(
              '🚦 [AuthService] Server responded with HTTP Status Code: $status',
            );
            return status == 200 ||
                status == 201 ||
                status == 400 ||
                status == 500;
          },
        ),
      );

      print('✅ [AuthService] Network request finished without crashing Dio.');
      print('📄 [AuthService] Response Raw Data Map: ${response.data}');
      return response;
    } on DioException catch (ex) {
      print('❌ [AuthService] A DioException was thrown!');
      print('❌ [AuthService] Exception Message: ${ex.message}');
      print('❌ [AuthService] Exception Type: ${ex.type}');
      print('❌ [AuthService] Response field state: ${ex.response}');
      print('❌ [AuthService] Response Body Data: ${ex.response?.data}');
      return ex.response;
    } catch (e) {
      print('💥 [AuthService] A totally unexpected system error occurred: $e');
      return null;
    }
  }

  Future<Response?> verifyOTP(String email, String otpCode) async {
    print('🌐 [AuthService] Initiating post request to verify OTP...');
    print('📦 [AuthService] Payload data: {email: $email, otpCode: $otpCode}');

    try {
      final response = await _dio.post(
        '/verify-otp', // 🟢 Ensure this matches your Node.js app's verification endpoint
        data: {
          'email':
              email, // 🟢 Sends the email text under the exact key your backend expects
          'otpCode': otpCode,
        },
        options: Options(
          validateStatus: (status) {
            print(
              '🚦 [AuthService] OTP Server responded with HTTP Status Code: $status',
            );
            // Accept 200, 201, 400, and 404 without crashing Dio!
            return status == 200 ||
                status == 201 ||
                status == 400 ||
                status == 404 ||
                status == 500;
          },
        ),
      );

      print('✅ [AuthService] OTP response payload: ${response.data}');
      return response;
    } on DioException catch (ex) {
      print(
        '❌ [AuthService] DioException during OTP verification: ${ex.message}',
      );
      return ex.response;
    } catch (e) {
      print('💥 [AuthService] Unexpected error during OTP call: $e');
      return null;
    }
  }

  Future<Response?> forgotPassword(String email) async {
    try {
      return await _dio.post('/forgot-password', data: {'email': email});
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      return await _dio.post(
        '/reset-password',
        data: {'email': email, 'token': token, 'newPassword': newPassword},
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  /// 🟢 Multipart Media Upload Client Method
  Future<Response?> updateProfilePicture(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      return await _dio.post(
        '/update-profile-picture',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (ex) {
      print('Multipart Upload API exception: ${ex.message}');
      return ex.response;
    }
  }

  /// 🟢 FIXED: Added required parameter `username` to match data map requirements down below
  Future<Response?> updateProfileText({
    required String name,
    required String bio,
    required String username,
  }) async {
    try {
      return await _dio.post(
        '/update-profile',
        data: {
          'name': name,
          'bio': bio,
          'username': username, // This compiles perfectly now!
        },
      );
    } on DioException catch (ex) {
      print('Profile Text Update Exception: ${ex.message}');
      return ex.response;
    }
  }
}
