import 'dart:io'; 
import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  // 🟢 Hook directly into the secure gateway client
  final Dio _dio = ApiClient().dio;

  Future<Response?> login(String username, String password) async {
    try {
      return await _dio.post(
        '/authenticate', 
        data: {'name': username, 'password': password},
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> getInfo() async {
    try {
      return await _dio.get('/getinfo');
    } on DioException catch (ex) {
      return ex.response;
    }
  }

 Future<Response?> register(String name, String email, String password) async {
  print('🌐 [AuthService] Initiating post request to /register...');
  print('📦 [AuthService] Payload data: {name: $name, email: $email}');
  
  try {
    final response = await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
      options: Options(
        validateStatus: (status) {
          print('🚦 [AuthService] Server responded with HTTP Status Code: $status');
          return status == 200 || status == 201 || status == 400 || status == 500;
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

  Future<Response?> verifyOtp(String username, String otpCode) async {
    try {
      return await _dio.post(
        '/verify-otp',
        data: {
          'name': username, 
          'otp': otpCode,
        },
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> forgotPassword(String email) async {
    try {
      return await _dio.post(
        '/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (ex) {
      return ex.response;
    }
  }

  Future<Response?> resetPassword(String email, String token, String newPassword) async {
    try {
      return await _dio.post(
        '/reset-password',
        data: {
          'email': email,
          'token': token, 
          'newPassword': newPassword,
        },
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
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data', 
          },
        ),
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