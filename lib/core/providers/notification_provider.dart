import 'dart:async';
import 'package:flutter/material.dart';
import '../notification_service.dart';
import '../config/notification_config.dart';
import '../../features/notifications/presentation/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  // Use configurable polling interval
  static Duration get defaultPollingInterval => NotificationConfig.providerPollingInterval;
  
  List<NotificationModel> _notifications = [];
  int _totalCount = 0;
  int _unreadCount = 0;
  int _readCount = 0;
  NotificationStats? _stats;
  bool _isLoading = false;
  Timer? _timer;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get totalCount => _totalCount;
  int get unreadCount => _unreadCount;
  int get readCount => _readCount;
  NotificationStats? get stats => _stats;
  bool get isLoading => _isLoading;

  // بدء الـ polling كل دقيقة
  void startPolling({Duration? interval}) {
    // إيقاف الـ timer القديم إذا كان موجود
    stopPolling();
    
    // جلب البيانات فوراً
    fetchNotifications();
    
    // بدء الـ timer الجديد
    final pollingInterval = interval ?? defaultPollingInterval;
    print('[NotificationProvider] Starting polling with interval: $pollingInterval');
    _timer = Timer.periodic(pollingInterval, (timer) {
      print('[NotificationProvider] Polling triggered at ${DateTime.now()}');
      fetchNotifications();
    });
  }

  // إيقاف الـ polling
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  // جلب الإشعارات
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.getNotifications();
      if (response != null) {
        _notifications = response.results;
        _totalCount = response.totalCount;
        _unreadCount = response.unreadCount;
        _readCount = response.readCount;
        _stats = response.stats;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تمييز إشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    final success = await _service.markAsRead(notificationId);
    if (success) {
      // تحديث الإشعار محلياً
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // يمكن تحديث الإشعار محلياً أو جلب البيانات من جديد
        fetchNotifications();
      }
    }
  }

  // تمييز جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    final success = await _service.markAllAsRead();
    if (success) {
      fetchNotifications();
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
} 