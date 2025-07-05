import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/auth/presentation/models/user_model.dart';
import '../../../../core/api_service.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../models/notification_model.dart';
import '../../../../config/routes/screens_name.dart';

// Simple in-app notification model
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? data;
  
  // NEW FIELDS FROM API
  final String? notificationType;
  final String? priority;
  final String? priorityDisplay;
  final String? typeDisplay;
  final String? timeAgo;
  final int? sender;
  final String? senderEmail;
  final int? receiver;
  final String? receiverEmail;
  final DateTime? readAt;
  final int? navigationId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    required this.type,
    this.data,
    // NEW FIELDS
    this.notificationType,
    this.priority,
    this.priorityDisplay,
    this.typeDisplay,
    this.timeAgo,
    this.sender,
    this.senderEmail,
    this.receiver,
    this.receiverEmail,
    this.readAt,
    this.navigationId,
  });

  // OLD copyWith method
  AppNotification copyWith({
    bool? isRead,
    String? title,
    String? message,
    DateTime? date,
    String? type,
    Map<String, dynamic>? data,
  }) => AppNotification(
        id: id,
        title: title ?? this.title,
        message: message ?? this.message,
        date: date ?? this.date,
        isRead: isRead ?? this.isRead,
        type: type ?? this.type,
        data: data ?? this.data,
        // NEW FIELDS
        notificationType: this.notificationType,
        priority: this.priority,
        priorityDisplay: this.priorityDisplay,
        typeDisplay: this.typeDisplay,
        timeAgo: this.timeAgo,
        sender: this.sender,
        senderEmail: this.senderEmail,
        receiver: this.receiver,
        receiverEmail: this.receiverEmail,
        readAt: this.readAt,
        navigationId: this.navigationId,
      );

  // NEW copyWith method with all fields
  AppNotification copyWithAll({
    bool? isRead,
    String? title,
    String? message,
    DateTime? date,
    String? type,
    Map<String, dynamic>? data,
    String? notificationType,
    String? priority,
    String? priorityDisplay,
    String? typeDisplay,
    String? timeAgo,
    int? sender,
    String? senderEmail,
    int? receiver,
    String? receiverEmail,
    DateTime? readAt,
    int? navigationId,
  }) => AppNotification(
        id: id,
        title: title ?? this.title,
        message: message ?? this.message,
        date: date ?? this.date,
        isRead: isRead ?? this.isRead,
        type: type ?? this.type,
        data: data ?? this.data,
        notificationType: notificationType ?? this.notificationType,
        priority: priority ?? this.priority,
        priorityDisplay: priorityDisplay ?? this.priorityDisplay,
        typeDisplay: typeDisplay ?? this.typeDisplay,
        timeAgo: timeAgo ?? this.timeAgo,
        sender: sender ?? this.sender,
        senderEmail: senderEmail ?? this.senderEmail,
        receiver: receiver ?? this.receiver,
        receiverEmail: receiverEmail ?? this.receiverEmail,
        readAt: readAt ?? this.readAt,
        navigationId: navigationId ?? this.navigationId,
      );

  // NEW: Factory method to create from API JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Debug logging for navigation_id
    print('[AppNotification.fromJson] Raw navigation_id: ${json['navigation_id']} (type: ${json['navigation_id']?.runtimeType})');
    
    // Handle navigation_id conversion safely
    int? navigationId;
    if (json['navigation_id'] != null) {
      if (json['navigation_id'] is int) {
        navigationId = json['navigation_id'];
      } else if (json['navigation_id'] is String) {
        navigationId = int.tryParse(json['navigation_id']);
        print('[AppNotification.fromJson] Converted navigation_id from string: $navigationId');
      } else {
        print('[AppNotification.fromJson] Unknown navigation_id type: ${json['navigation_id'].runtimeType}');
      }
    }

    // Debug logging for other fields
    print('[AppNotification.fromJson] Raw sender_id: ${json['sender_id']} (type: ${json['sender_id']?.runtimeType})');
    print('[AppNotification.fromJson] Raw receiver_id: ${json['receiver_id']} (type: ${json['receiver_id']?.runtimeType})');
    
    // Handle sender_id conversion safely
    int? senderId;
    if (json['sender_id'] != null) {
      if (json['sender_id'] is int) {
        senderId = json['sender_id'];
      } else if (json['sender_id'] is String) {
        senderId = int.tryParse(json['sender_id']);
      }
    }

    // Handle receiver_id conversion safely
    int? receiverId;
    if (json['receiver_id'] != null) {
      if (json['receiver_id'] is int) {
        receiverId = json['receiver_id'];
      } else if (json['receiver_id'] is String) {
        receiverId = int.tryParse(json['receiver_id']);
      }
    }

    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      type: json['notification_type'] ?? 'SYSTEM',
      data: json['data'] ?? {},
      // NEW FIELDS
      notificationType: json['notification_type'],
      priority: json['priority'],
      priorityDisplay: json['priority_display'],
      typeDisplay: json['type_display'],
      timeAgo: json['time_ago'],
      sender: senderId, // Use converted value
      senderEmail: json['sender_email'],
      receiver: receiverId, // Use converted value
      receiverEmail: json['receiver_email'],
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
      navigationId: navigationId, // Use converted value
    );
  }

  @override
  List<Object?> get props => [
    id, title, message, date, isRead, type, data,
    notificationType, priority, priorityDisplay, typeDisplay, timeAgo,
    sender, senderEmail, receiver, receiverEmail, readAt, navigationId,
  ];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  const NotificationLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  static NotificationCubit get(context) => BlocProvider.of(context);
  
  // Local storage for in-app notifications
  List<AppNotification> _localNotifications = [];
  
  // Get all notifications (both from API and local)
  Future<void> getAllNotifications() async {
    emit(NotificationLoading());
    try {
      // Get notifications from backend API
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        // OLD: Using notifications/ endpoint
        // final response = await ApiService().getWithToken("notifications/", token);
        
        // NEW: Using the correct API endpoint
        final response = await ApiService().getWithToken("notifications/notifications/", token);
        
        if (response.statusCode == 200) {
          // OLD: Using NotificationResponse.fromJson
          // final notificationResponse = NotificationResponse.fromJson(response.data);
          
          // NEW: Direct parsing from API response
          final data = response.data;
          final List<dynamic> results = data['results'] ?? [];
          
          // Debug: Print first notification data structure
          if (results.isNotEmpty) {
            print('[getAllNotifications] First notification raw data:');
            print(results.first);
            print('[getAllNotifications] First notification keys: ${results.first.keys.toList()}');
          }
          
          // Convert API notifications to AppNotification format using fromJson
          final apiNotifications = results.map((json) {
            try {
              return AppNotification.fromJson(json);
            } catch (e) {
              print('[getAllNotifications] Error parsing notification: $e');
              print('[getAllNotifications] Problematic JSON: $json');
              rethrow;
            }
          }).toList();
          
          // Combine API notifications with local notifications
          _localNotifications = [...apiNotifications, ..._localNotifications];
          
          print('✅ Successfully loaded ${apiNotifications.length} notifications from API');
          print('[getAllNotifications] Sample notification navigation_id: ${apiNotifications.isNotEmpty ? apiNotifications.first.navigationId : 'N/A'}');
        } else {
          print('❌ API Error: ${response.statusCode} - ${response.data}');
        }
      } else {
        print('❌ No access token found');
      }
      
      emit(NotificationLoaded(_localNotifications));
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      // If API fails, still show local notifications
      emit(NotificationLoaded(_localNotifications));
    }
  }

  // Add a new in-app notification
  void addNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      date: DateTime.now(),
      isRead: false,
      type: type,
      data: data,
    );
    
    _localNotifications.insert(0, notification);
    
    if (state is NotificationLoaded) {
      emit(NotificationLoaded(_localNotifications));
    } else {
      emit(NotificationLoaded(_localNotifications));
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // OLD: Only local update
      // _localNotifications = _localNotifications.map((notification) {
      //   if (notification.id == notificationId) {
      //     return notification.copyWith(isRead: true);
      //   }
      //   return notification;
      // }).toList();
      
      // NEW: Update via API first, then locally
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        // Call API to mark as read
        final response = await ApiService().postWithToken(
          "notifications/notifications/$notificationId/mark_as_read/",
          {}
        );
        
        if (response.statusCode == 200) {
          print('✅ Successfully marked notification $notificationId as read via API');
        } else {
          print('❌ Failed to mark notification as read via API: ${response.statusCode}');
        }
      }
      
      // Update locally regardless of API result
      _localNotifications = _localNotifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(_localNotifications));
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      // Still update locally even if API fails
      _localNotifications = _localNotifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(_localNotifications));
      }
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // OLD: Only local update
      // _localNotifications = _localNotifications.map((notification) {
      //   return notification.copyWith(isRead: true);
      // }).toList();
      
      // NEW: Update via API first, then locally
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        // Call API to mark all as read
        final response = await ApiService().postWithToken(
          "notifications/notifications/mark_all_as_read/",
          {}
        );
        
        if (response.statusCode == 200) {
          print('✅ Successfully marked all notifications as read via API');
        } else {
          print('❌ Failed to mark all notifications as read via API: ${response.statusCode}');
        }
      }
      
      // Update locally regardless of API result
      _localNotifications = _localNotifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(_localNotifications));
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      // Still update locally even if API fails
      _localNotifications = _localNotifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(_localNotifications));
      }
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    _localNotifications.clear();
    emit(NotificationLoaded(_localNotifications));
  }

  // Get unread count
  int get unreadCount {
    return _localNotifications.where((notification) => !notification.isRead).length;
  }

  // NEW: Get notifications count from API
  Future<Map<String, int>> getNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        final response = await ApiService().getWithToken("notifications/notifications/count/", token);
        if (response.statusCode == 200) {
          final data = response.data;
          return {
            'total': data['total_count'] ?? 0,
            'unread': data['unread_count'] ?? 0,
            'read': data['read_count'] ?? 0,
          };
        }
      }
      return {'total': 0, 'unread': 0, 'read': 0};
    } catch (e) {
      print('❌ Error getting notifications count: $e');
      return {'total': 0, 'unread': 0, 'read': 0};
    }
  }

  // NEW: Get unread notifications only
  Future<void> getUnreadNotifications() async {
    emit(NotificationLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        final response = await ApiService().getWithToken("notifications/notifications/unread/", token);
        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> results = data['results'] ?? [];
          
          final unreadNotifications = results.map((json) => 
            AppNotification.fromJson(json)
          ).toList();
          
          emit(NotificationLoaded(unreadNotifications));
          print('✅ Successfully loaded ${unreadNotifications.length} unread notifications');
        } else {
          print('❌ API Error: ${response.statusCode} - ${response.data}');
          emit(NotificationError('فشل في جلب الإشعارات غير المقروءة'));
        }
      } else {
        print('❌ No access token found');
        emit(NotificationError('لم يتم العثور على رمز الوصول'));
      }
    } catch (e) {
      print('❌ Error fetching unread notifications: $e');
      emit(NotificationError('خطأ في جلب الإشعارات غير المقروءة: $e'));
    }
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(String type) {
    return _localNotifications.where((notification) => notification.type == type).toList();
  }

  // Send booking notifications (triggered from booking flow)
  void sendBookingNotification({
    required String renterName,
    required String carBrand,
    required String carModel,
    required String ownerId,
    required String renterId,
    required String type, // 'booking_request', 'booking_accepted', 'booking_declined'
    double? totalPrice,
    String? rentalId,
  }) {
    String title;
    String message;
    
    switch (type) {
      case 'booking_request':
        title = 'New Booking Request';
        message = '$renterName wants to rent your $carBrand $carModel';
        break;
      case 'booking_accepted':
        title = 'Booking Accepted';
        message = 'Your booking request for $carBrand $carModel has been accepted';
        break;
      case 'booking_declined':
        title = 'Booking Declined';
        message = 'Your booking request for $carBrand $carModel has been declined';
        break;
      default:
        title = 'Booking Update';
        message = 'Your booking for $carBrand $carModel has been updated';
    }
    
    final Map<String, dynamic> notificationData = {
      'renterName': renterName,
      'carBrand': carBrand,
      'carModel': carModel,
      'ownerId': ownerId,
      'renterId': renterId,
    };
    if (type == 'booking_accepted') {
      notificationData['totalPrice'] = totalPrice ?? 0.0;
      notificationData['rentalId'] = rentalId ?? 'unknown';
    }
    
    addNotification(
      title: title,
      message: message,
      type: type,
      data: notificationData,
    );
  }

  // Send payment notifications
  void sendPaymentNotification({
    required String amount,
    required String carBrand,
    required String carModel,
    required String type, // 'deposit_paid', 'payment_completed', 'refund_processed'
  }) {
    String title;
    String message;
    
    switch (type) {
      case 'deposit_paid':
        title = 'Deposit Paid';
        message = 'Deposit of \$$amount has been paid for $carBrand $carModel';
        break;
      case 'payment_completed':
        title = 'Payment Completed';
        message = 'Payment of \$$amount has been completed for $carBrand $carModel';
        break;
      case 'refund_processed':
        title = 'Refund Processed';
        message = 'Refund of \$$amount has been processed for $carBrand $carModel';
        break;
      default:
        title = 'Payment Update';
        message = 'Payment update for $carBrand $carModel';
    }
    
    addNotification(
      title: title,
      message: message,
      type: type,
      data: {
        'amount': amount,
        'carBrand': carBrand,
        'carModel': carModel,
      },
    );
  }

  // Send handover notifications
  void sendHandoverNotification({
    required String carBrand,
    required String carModel,
    required String type, // 'handover_started', 'handover_completed', 'handover_cancelled'
    String? userName,
  }) {
    String title;
    String message;
    
    switch (type) {
      case 'handover_started':
        title = 'Handover Started';
        message = 'Handover process has started for $carBrand $carModel';
        break;
      case 'handover_completed':
        title = 'Handover Completed';
        message = 'Handover has been completed for $carBrand $carModel';
        break;
      case 'handover_cancelled':
        title = 'Handover Cancelled';
        message = 'Handover has been cancelled for $carBrand $carModel';
        break;
      default:
        title = 'Handover Update';
        message = 'Handover update for $carBrand $carModel';
    }
    
    addNotification(
      title: title,
      message: message,
      type: type,
      data: {
        'carBrand': carBrand,
        'carModel': carModel,
        'userName': userName,
      },
    );
  }

  // Send trip notifications
  void sendTripNotification({
    required String carBrand,
    required String carModel,
    required String type, // 'trip_started', 'trip_completed', 'trip_cancelled'
  }) {
    String title;
    String message;
    
    switch (type) {
      case 'trip_started':
        title = 'Trip Started';
        message = 'Your trip with $carBrand $carModel has started';
        break;
      case 'trip_completed':
        title = 'Trip Completed';
        message = 'Your trip with $carBrand $carModel has been completed';
        break;
      case 'trip_cancelled':
        title = 'Trip Cancelled';
        message = 'Your trip with $carBrand $carModel has been cancelled';
        break;
      default:
        title = 'Trip Update';
        message = 'Trip update for $carBrand $carModel';
    }
    
    addNotification(
      title: title,
      message: message,
      type: type,
      data: {
        'carBrand': carBrand,
        'carModel': carModel,
      },
    );
  }

  // جلب الإشعارات الجديدة فقط وإضافتها على القائمة بدون تكرار
  Future<void> fetchNewNotifications() async {
    print('[fetchNewNotifications] called at: ' + DateTime.now().toIso8601String());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null) {
        final response = await ApiService().getWithToken("notifications/notifications/", token);
        print('[fetchNewNotifications] API status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> results = data['results'] ?? [];
          
          // Debug: Print first notification data structure
          if (results.isNotEmpty) {
            print('[fetchNewNotifications] First notification raw data:');
            print(results.first);
            print('[fetchNewNotifications] First notification keys: ${results.first.keys.toList()}');
          }
          
          final newNotifications = results.map((json) {
            try {
              return AppNotification.fromJson(json);
            } catch (e) {
              print('[fetchNewNotifications] Error parsing notification: $e');
              print('[fetchNewNotifications] Problematic JSON: $json');
              rethrow;
            }
          }).toList();

          // احصل على الـ IDs الحالية
          final currentIds = _localNotifications.map((n) => n.id).toSet();

          // أضف فقط الإشعارات الجديدة
          final onlyNew = newNotifications.where((n) => !currentIds.contains(n.id)).toList();
          print('[fetchNewNotifications] found ${onlyNew.length} new notifications');
          for (final n in onlyNew) {
            print('[fetchNewNotifications] new notification id: ${n.id}, navigation_id: ${n.navigationId}');
          }
          if (onlyNew.isNotEmpty) {
            _localNotifications = [...onlyNew, ..._localNotifications];
            print('[fetchNewNotifications] total notifications after merge: ${_localNotifications.length}');
            emit(NotificationLoaded(_localNotifications));
          }
        } else {
          print('[fetchNewNotifications] API error: ${response.statusCode} - ${response.data}');
        }
      } else {
        print('[fetchNewNotifications] No access token found');
      }
    } catch (e) {
      print('[fetchNewNotifications] error: $e');
      print('[fetchNewNotifications] error stack trace: ${StackTrace.current}');
      // تجاهل الخطأ في التحديث التلقائي
    }
  }

  // NEW: Navigate based on navigation_id
  void navigateBasedOnNotification(BuildContext context, AppNotification notification) {
    if (notification.navigationId == null) {
      print('[navigateBasedOnNotification] No navigation_id provided for notification: ${notification.id}');
      return;
    }

    print('[navigateBasedOnNotification] Navigating with navigation_id: ${notification.navigationId}');
    
    // Mark notification as read when navigating
    markAsRead(notification.id);

    // Navigate based on navigation_id
    switch (notification.navigationId) {
      case 1: // Booking details
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen);
        break;
      case 2: // Trip details
        Navigator.pushNamed(context, ScreensName.tripDetailsScreen);
        break;
      case 3: // Payment details
        Navigator.pushNamed(context, ScreensName.paymentScreen);
        break;
      case 4: // Car details
        // You might need to pass car data here
        Navigator.pushNamed(context, ScreensName.showCarDetailsScreen);
        break;
      case 5: // Profile
        Navigator.pushNamed(context, ScreensName.profile);
        break;
      case 6: // Notifications
        Navigator.pushNamed(context, ScreensName.newnotifytest);
        break;
      case 7: // Home
        Navigator.pushNamed(context, ScreensName.homeScreen);
        break;
      case 8: // Owner notifications
        Navigator.pushNamed(context, ScreensName.newnotifytest);
        break;
      case 9: // Owner home
        Navigator.pushNamed(context, ScreensName.ownerHomeScreen);
        break;
      default:
        print('[navigateBasedOnNotification] Unknown navigation_id: ${notification.navigationId}');
        // Default to home screen
        Navigator.pushNamed(context, ScreensName.homeScreen);
        break;
    }
  }

  // NEW: Get notification by ID
  AppNotification? getNotificationById(String id) {
    try {
      return _localNotifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      print('[getNotificationById] Notification not found with id: $id');
      return null;
    }
  }

  // NEW: Get notifications by priority
  List<AppNotification> getNotificationsByPriority(String priority) {
    return _localNotifications.where((notification) => 
      notification.priority == priority
    ).toList();
  }

  // NEW: Get high priority notifications
  List<AppNotification> getHighPriorityNotifications() {
    return _localNotifications.where((notification) => 
      notification.priority == 'HIGH' || notification.priority == 'URGENT'
    ).toList();
  }

  // NEW: Get notifications by sender
  List<AppNotification> getNotificationsBySender(int senderId) {
    return _localNotifications.where((notification) => 
      notification.sender == senderId
    ).toList();
  }

  // NEW: Get notifications by receiver
  List<AppNotification> getNotificationsByReceiver(int receiverId) {
    return _localNotifications.where((notification) => 
      notification.receiver == receiverId
    ).toList();
  }

  // NEW: Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        // Call API to delete notification
        final response = await ApiService().deleteWithToken(
          "notifications/notifications/$notificationId/",
          token
        );
        
        if (response.statusCode == 204 || response.statusCode == 200) {
          print('✅ Successfully deleted notification $notificationId via API');
        } else {
          print('❌ Failed to delete notification via API: ${response.statusCode}');
        }
      }
      
      // Remove from local list
      _localNotifications.removeWhere((notification) => notification.id == notificationId);
      
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(_localNotifications));
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      // Still remove locally even if API fails
      _localNotifications.removeWhere((notification) => notification.id == notificationId);
      
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(_localNotifications));
      }
    }
  }

  // NEW: Get notification statistics
  Map<String, int> getNotificationStatistics() {
    final total = _localNotifications.length;
    final unread = _localNotifications.where((n) => !n.isRead).length;
    final read = total - unread;
    final highPriority = _localNotifications.where((n) => 
      n.priority == 'HIGH' || n.priority == 'URGENT'
    ).length;

    return {
      'total': total,
      'unread': unread,
      'read': read,
      'highPriority': highPriority,
    };
  }
} 