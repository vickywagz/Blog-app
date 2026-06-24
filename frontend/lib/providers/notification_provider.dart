import 'package:blog_app/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// 🟢 STEP 1: Import your centralized api client file
import 'package:blog_app/services/api_client.dart'; // Adjust path based on your folder structure

class NotificationProvider with ChangeNotifier {
  // 🟢 STEP 2: Swap the raw Dio instance with your shared ApiClient instance
  final Dio _dio = ApiClient().dio; 
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // 🟢 GET: Fetch all notifications for the user
  // 🟢 GET: Fetch all notifications for the user
  Future<void> fetchNotifications() async {
    debugPrint("🔵 Provider: fetchNotifications() invoked.");
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/notifications');
      debugPrint("🔵 Provider: HTTP GET /notifications response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        // 🟢 FIX: Handle both a raw list or an object map wrapper structure
        List rawList = [];
        
        if (response.data is List) {
          rawList = response.data;
        } else if (response.data is Map) {
          // If your backend wraps it in a key like "notifications", "data", or "results"
          rawList = response.data['notifications'] ?? response.data['data'] ?? [];
        }

        debugPrint("🟢 Provider: Successfully parsed ${rawList.length} records into list.");
        _notifications = rawList.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("🔴 Provider Error [fetchNotifications]: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🟢 PATCH/PUT: Mark a single notification as read
  Future<void> markAsRead(String id) async {
    debugPrint("🔵 Provider: markAsRead() invoked for ID: $id");
    
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final n = _notifications[index];
      _notifications[index] = NotificationModel(
        id: n.id,
        type: n.type,
        isRead: true, 
        senderName: n.senderName,
        senderAvatar: n.senderAvatar,
        postTitle: n.postTitle,
        postId: n.postId,
        createdAt: n.createdAt,
      );
      debugPrint("🟢 Provider: Local cache state updated optimistically to isRead = true.");
      notifyListeners();
    } else {
      debugPrint("⚠️ Provider Warning: Could not locate ID $id in local memory cache collection.");
    }

    try {
      debugPrint("🔵 Provider: Syncing read state to backend via PUT /notifications/$id/mark-read...");
      final response = await _dio.put('/notifications/$id/mark-read'); 
      debugPrint("🟢 Provider: Backend sync complete with status code: ${response.statusCode}");
    } catch (e) {
      debugPrint("🔴 Provider Error [markAsRead Sync]: $e");
    }
  }

  // 🟢 PUT: Mark all notifications as read instantly
  Future<void> markAllAsRead() async {
    debugPrint("🔵 Provider: markAllAsRead() invoked.");
    try {
      final response = await _dio.put('/notifications/mark-read');
      debugPrint("🔵 Provider: HTTP PUT /notifications/mark-read status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          type: n.type,
          isRead: true, 
          senderName: n.senderName,
          senderAvatar: n.senderAvatar,
          postTitle: n.postTitle,
          postId: n.postId,
          createdAt: n.createdAt,
        )).toList();
        
        debugPrint("🟢 Provider: All local items updated to read status successfully.");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("🔴 Provider Error [markAllAsRead]: $e");
    }
  }
}