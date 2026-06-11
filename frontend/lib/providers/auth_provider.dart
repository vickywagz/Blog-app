import 'package:blog_app/models/user.dart';
import 'package:blog_app/services/auth_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// A simple response wrapper class to pass backend messages up to your text field validators
class AuthResult {
  final bool success;
  final String message;
  AuthResult({required this.success, required this.message});
}

class AuthProvider with ChangeNotifier {
  late final FlutterSecureStorage storage;
  User? _user;
  bool _isLoading = true; // Start as true so the splash screen stays active during token lookup

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    storage = const FlutterSecureStorage();
    initialData();
  }

  /// 1. App Startup: Reads the device keychain storage for existing log tokens
  Future<void> initialData() async {
    try {
      final token = await storage.read(key: 'token');
      if (token != null) {
        await getUserInfo(token);
      }
    } catch (e) {
      debugPrint("Error reading secure storage: $e");
    } finally {
      _isLoading = false; // Registration/initial token check cycle complete
      notifyListeners();  // Triggers GoRouter to make its safe routing choice
    }
  }

  /// 2. Handles user login requests and maps backend errors for text field validation
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
          await getUserInfo(token);
          
          return AuthResult(success: true, message: 'Login successful');
        } else {
          // Pass the exact backend validation failure message up to the screen layer
          return AuthResult(
            success: false, 
            message: userdata.data['msg'] ?? 'Login failed. Please verify credentials.',
          );
        }
      }
      return AuthResult(success: false, message: 'Server returned an empty response.');
    } catch (error) {
      return AuthResult(success: false, message: 'Connection timeout. Is your backend server awake?');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3. Standard Registration Processing Pipeline
  Future<AuthResult> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      Response? userdata = await AuthService().register(username, password);
      bool success = userdata?.data['success'] == true;

      if (success) {
        return AuthResult(success: true, message: userdata?.data['msg'] ?? 'Account created successfully.');
      } else {
        return AuthResult(success: false, message: userdata?.data['msg'] ?? 'Registration failed.');
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network connection failed.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 4. Decodes Profile structures using raw Authorization Headers
  Future<void> getUserInfo(String? token) async {
    try {
      var res = await AuthService().getInfo(token);
      if (res != null && res.data != null && res.data['success'] == true) {
        _user = User.fromJson(res.data);
      } else {
        _user = null;
        await storage.delete(key: 'token'); // Clear corrupted/expired tokens safely
      }
    } catch (e) {
      _user = null;
    }
  }

  /// 5. Full Account Session Revocation Flow
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _user = null;
    await storage.delete(key: 'token'); // Explicitly target your token key instead of wiping everything

    _isLoading = false;
    notifyListeners();
  }
}