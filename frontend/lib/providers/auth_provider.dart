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

  Future<AuthResult> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? userdata = await AuthService().login(username, password);

      if (userdata != null && userdata.data != null) {
        bool isAuthenticate = userdata.data['success'] == true;

        if (isAuthenticate) {
          final token = userdata.data['token'];
          await storage.write(key: 'token', value: token);
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
      return AuthResult(
        success: false,
        message: 'Connection timeout. Is your backend server awake?',
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
    _isLoading = true;
    notifyListeners();

    try {
      // Forward all three fields to your AuthService network client
      Response? userdata = await AuthService().register(name, email, password);
      bool success = userdata?.data['success'] == true;

      if (success) {
        return AuthResult(
          success: true,
          message: userdata?.data['msg'] ?? 'Account created successfully.',
        );
      } else {
        return AuthResult(
          success: false,
          message: userdata?.data['msg'] ?? 'Registration failed.',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network connection failed.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserInfo() async {
    try {
      var res = await AuthService().getInfo();
      if (res != null && res.data != null && res.data['success'] == true) {
        _user = User.fromJson(res.data);
      } else {
        _user = null;
        await storage.delete(key: 'token');
      }
    } catch (e) {
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
    _isLoading = true;
    notifyListeners();

    try {
      Response? response = await AuthService().verifyOtp(username, otpCode);
      bool success = response?.data['success'] == true;

      if (success) {
        return AuthResult(
          success: true,
          message: response?.data['msg'] ?? 'Verification successful!',
        );
      } else {
        return AuthResult(
          success: false,
          message: response?.data['msg'] ?? 'Invalid or expired OTP code.',
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
