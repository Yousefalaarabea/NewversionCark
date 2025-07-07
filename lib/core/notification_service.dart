import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/notifications/presentation/models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'https://brandon-moderators-thorough-strict.trycloudflare.com/api/'; // غير للـ URL بتاعك
  
  // دالة للحصول على الـ token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // return prefs.getString('auth_token');
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjo0OTA1MjcwOTY0LCJpYXQiOjE3NTE2NzA5NjQsImp0aSI6ImViMDhkMmY2NWE3ZjRjN2E5YjBmY2VlNDM3ZGRlMzg1IiwidXNlcl9pZCI6Mn0.eV3mPVEo08-lgvSefsYTAzvekiPmbWDxsaLBkaKjAYw";
  }

  // دالة لجلب الإشعارات
  Future<NotificationResponse?> getNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NotificationResponse.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getNotifications: $e');
      return null;
    }
  }

  // دالة لتمييز إشعار كمقروء
  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/notifications/$notificationId/mark_as_read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Exception in markAsRead: $e');
      return false;
    }
  }

  // دالة لتمييز جميع الإشعارات كمقروءة
  Future<bool> markAllAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/notifications/mark_all_as_read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Exception in markAllAsRead: $e');
      return false;
    }
  }
} 