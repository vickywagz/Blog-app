import 'dart:io';
import 'package:blog_app/models/user.dart';
import 'package:blog_app/services/auth_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthResult {
  final bool success;
  final String message;
  AuthResult({required this.success, required this.message});
}

class AuthProvider with ChangeNotifier {
  late final FlutterSecureStorage storage;
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    storage = const FlutterSecureStorage();
    initialData();
  }

  Future<void> initialData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token != null) {
        await getUserInfo();
      }
    } catch (e) {
      debugPrint("Error reading secure storage: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> login(String email, String password) async {
    print('🚀 [AuthProvider] login method started for: $email');
    _isLoading = true;
    notifyListeners();

    try {
      print('⏳ [AuthProvider] Awaiting AuthService().login...');
      Response? userdata = await AuthService().login(email, password);

      print(
        '📥 [AuthProvider] response status code => ${userdata?.statusCode}',
      );

      if (userdata != null && userdata.data != null) {
        // 🟢 FIXED: Crash Guard. Check if response is a Map or JSON layout string
        if (userdata.data is! Map) {
          print(
            '⚠️ [AuthProvider] Server returned a non-JSON payload format (likely a 404 or 500 HTML error page).',
          );
          return AuthResult(
            success: false,
            message:
                'Server route mismatch (HTTP ${userdata.statusCode}). Check endpoint settings.',
          );
        }

        // Safe to treat as Map now!
        bool isAuthenticate = userdata.data['success'] == true;
        print(
          '📥 [AuthProvider] Calculated authentication status flag: $isAuthenticate',
        );

        if (isAuthenticate) {
          final token = userdata.data['token'];
          if (token != null) {
            await storage.write(key: 'token', value: token);
            print('🔒 [AuthProvider] JWT Token written securely to storage.');
          }

          await getUserInfo();
          return AuthResult(success: true, message: 'Login successful');
        } else {
          return AuthResult(
            success: false,
            message:
                userdata.data['msg'] ??
                'Login failed. Please verify credentials.',
          );
        }
      }

      return AuthResult(
        success: false,
        message: 'Server returned an empty response.',
      );
    } catch (error) {
      print('💥 [AuthProvider] Catch block intercepted failure: $error');
      return AuthResult(
        success: false,
        message: 'An unexpected processing error occurred.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🟢 UPDATE: Accept name, email, and password parameters
  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    print('🚀 [AuthProvider] Method started.');
    _isLoading = true;
    notifyListeners();

    try {
      print('⏳ [AuthProvider] Awaiting AuthService().register...');
      Response? userdata = await AuthService().register(name, email, password);

      print(
        '📥 [AuthProvider] AuthService returned control. Data check below:',
      );
      print(
        '📥 [AuthProvider] userdata variable is null? => ${userdata == null}',
      );
      print(
        '📥 [AuthProvider] userdata status code => ${userdata?.statusCode}',
      );
      print('📥 [AuthProvider] userdata body map => ${userdata?.data}');

      bool success = userdata?.data['success'] == true;
      print(
        '📥 [AuthProvider] calculated "success" boolean evaluates to: $success',
      );

      if (success) {
        print('🎉 [AuthProvider] Success branch matched!');
        return AuthResult(
          success: true,
          message: userdata?.data['msg'] ?? 'Account created successfully.',
        );
      } else {
        print(
          '⚠️ [AuthProvider] Server explicitly returned false success property.',
        );
        return AuthResult(
          success: false,
          message: userdata?.data['msg'] ?? 'Registration failed.',
        );
      }
    } on DioException catch (ex) {
      print(
        '🚨 [AuthProvider] Block trapped inside an "on DioException" catch wrapper!',
      );
      if (ex.response != null && ex.response?.data != null) {
        final responseData = ex.response?.data;
        final bool isSuccess = responseData['success'] == true;
        final String serverMessage =
            responseData['msg'] ?? 'Registration failed.';

        print(
          '🚨 [AuthProvider] Pulled data from exception response context successfully.',
        );
        print(
          '🚨 [AuthProvider] Extracted Message: $serverMessage, Success value: $isSuccess',
        );

        return AuthResult(success: isSuccess, message: serverMessage);
      }

      print(
        '🚨 [AuthProvider] No response data present inside the exception frame.',
      );
      return AuthResult(success: false, message: 'Network connection failed.');
    } catch (e) {
      print('💥 [AuthProvider] Caught general execution flow failure: $e');
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred.',
      );
    } finally {
      print(
        '🏁 [AuthProvider] Entering finally block. Setting loading flag to false.',
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserInfo() async {
    print('⏳ [AuthProvider] getUserInfo pipeline started...');
    try {
      var res = await AuthService().getInfo();

      print('📥 [AuthProvider] getInfo HTTP status code => ${res?.statusCode}');
      print('📥 [AuthProvider] getInfo server body data => ${res?.data}');

      // 🟢 FIX: Handle cases where server returns raw text string like "Unauthorized" instead of a Map
      if (res == null || res.data == null || res.data is! Map) {
        print(
          '⚠️ [AuthProvider] Server returned empty or raw non-JSON data (e.g., HTTP 401 text string).',
        );
        _user = null;
        return;
      }

      // Safe to perform map key checking now!
      if (res.data['success'] == true) {
        // Extract 'user' block if your API nests user data fields
        final userDataMap = res.data['user'] ?? res.data;

        _user = User.fromJson(userDataMap);
        print(
          '🎉 [AuthProvider] Profile layout parsed successfully! Current User ID: ${_user?.id}',
        );
      } else {
        print(
          '⚠️ [AuthProvider] Server explicitly rejected token validation profile load.',
        );
        _user = null;
      }
    } catch (e) {
      print(
        '💥 [AuthProvider] Critical exception crashed getUserInfo processing: $e',
      );
      _user = null;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _user = null;
    await storage.delete(key: 'token');

    _isLoading = false;
    notifyListeners();
  }

  Future<AuthResult> verifyAccountOtp(String username, String otpCode) async {
    print('🚀 [AuthProvider] verifyAccountOtp started.');
    print(
      '📦 [AuthProvider] Inputs passed -> username/email: $username, otpCode: $otpCode',
    );

    _isLoading = true;
    notifyListeners();

    try {
      print('⏳ [AuthProvider] Awaiting AuthService().verifyOTP...');
      // 🟢 FIXED: Explicitly calling verifyOTP matching the precise naming case above
      Response? response = await AuthService().verifyOTP(username, otpCode);

      print('📥 [AuthProvider] AuthService returned control.');
      print(
        '📥 [AuthProvider] response context is null? => ${response == null}',
      );
      print(
        '📥 [AuthProvider] response status code => ${response?.statusCode}',
      );
      print('📥 [AuthProvider] response raw body data => ${response?.data}');

      bool success = response?.data['success'] == true;
      print('📥 [AuthProvider] Calculated success outcome => $success');

      if (success) {
        print('🎉 [AuthProvider] OTP Success branch matched!');
        return AuthResult(
          success: true,
          message: response?.data['msg'] ?? 'Verification successful!',
        );
      } else {
        print(
          '⚠️ [AuthProvider] Server explicitly rejected the OTP matching sequence.',
        );
        return AuthResult(
          success: false,
          message: response?.data['msg'] ?? 'Invalid or expired OTP code.',
        );
      }
    } catch (e) {
      print(
        '💥 [AuthProvider] Caught execution flow failure during OTP process: $e',
      );
      return AuthResult(
        success: false,
        message: 'Server communication failure.',
      );
    } finally {
      print(
        '🏁 [AuthProvider] Entering finally block. Lowering loading state flags.',
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? response = await AuthService().forgotPassword(email);
      bool success = response?.data['success'] == true;

      if (success) {
        return AuthResult(
          success: true,
          message: response?.data['msg'] ?? 'Recovery code sent successfully!',
        );
      } else {
        return AuthResult(
          success: false,
          message: response?.data['msg'] ?? 'Failed to send recovery code.',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Server communication failure.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? response = await AuthService().resetPassword(
        email,
        token,
        newPassword,
      );
      bool success = response?.data['success'] == true;

      if (success) {
        return AuthResult(
          success: true,
          message: response?.data['msg'] ?? 'Password updated successfully!',
        );
      } else {
        return AuthResult(
          success: false,
          message: response?.data['msg'] ?? 'Failed to reset password.',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Server communication failure.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🟢 FIXED: Switched from UserService to AuthService and replaced _setLoading() with explicit local flag state assignments
  Future<bool> uploadProfileImage(File file) async {
    _isLoading = true;
    notifyListeners();

    Response? res = await AuthService().updateProfilePicture(file);

    if (res != null && res.statusCode == 200) {
      final newImageUrl = res.data['user']['profileImage'] ?? res.data['url'];

      if (_user != null && newImageUrl != null) {
        // Fallback implementation if your model lacks a copyWith generator method
        _user = User(
          id: _user!.id,
          name: _user!.name,
          username: _user!.username,
          email: _user!.email,
          bio: _user!.bio,
          profilePicture: _user!.profilePicture,
          isVerified: _user!.isVerified,
          profileImage: newImageUrl, // Inject fresh asset string
        );
        notifyListeners();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// 🟢 FIXED: Replaced _setLoading() with actual boolean state mutators and passed username to backend service hook
  Future<bool> updateProfileDetails({
    required String name,
    required String bio,
    required String username,
  }) async {
    _isLoading = true;
    notifyListeners();

    Response? res = await AuthService().updateProfileText(
      name: name,
      bio: bio,
      username: username,
    );

    if (res != null && res.statusCode == 200) {
      if (_user != null) {
        _user = User(
          id: _user!.id,
          name: name,
          username: username,
          email: _user!.email,
          bio: bio,
          profilePicture: _user!.profilePicture,
          isVerified: _user!.isVerified,
          profileImage: _user!.profileImage,
        );
        notifyListeners();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
