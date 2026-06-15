import 'package:blog_app/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NotificationProvider with ChangeNotifier {
  // Replace with your real base deployment network URL when ready
  final Dio _dio = Dio(BaseOptions(baseUrl: 'YOUR_BACKEND_API_URL_HERE')); 
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // 🟢 GET: Fetch all notifications for the user
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/notifications');
      if (response.statusCode == 200) {
        final List data = response.data;
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🟢 PUT: Mark all notifications as read instantly
  Future<void> markAllAsRead() async {
    try {
      final response = await _dio.put('/notifications/mark-read');
      if (response.statusCode == 200) {
        // 🟢 Optimistically update the exact model schema structures locally
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          type: n.type,
          isRead: true, // Set flag to true
          senderName: n.senderName,
          senderAvatar: n.senderAvatar,
          postTitle: n.postTitle,
          postId: n.postId,
          createdAt: n.createdAt,
        )).toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking notifications read: $e");
    }
  }
}