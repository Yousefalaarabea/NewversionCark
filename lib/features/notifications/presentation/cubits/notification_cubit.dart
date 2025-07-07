import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/auth/presentation/models/user_model.dart';
import '../../../../core/api_service.dart';
import '../../../../core/config/notification_config.dart';
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
  final String? navigationId;

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
    String? navigationId,
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
    String? navigationId;
    if (json['navigation_id'] != null) {
      if (json['navigation_id'] is String) {
        navigationId = json['navigation_id'];
        print('[AppNotification.fromJson] Using navigation_id as string: $navigationId');
      } else if (json['navigation_id'] is int) {
        navigationId = json['navigation_id'].toString();
        print('[AppNotification.fromJson] Converted navigation_id from int: $navigationId');
      } else {
        print('[AppNotification.fromJson] Unknown navigation_id type: ${json['navigation_id'].runtimeType}');
      }
    }

    // Debug logging for other fields
    print('[AppNotification.fromJson] Raw sender: ${json['sender']} (type: ${json['sender']?.runtimeType})');
    print('[AppNotification.fromJson] Raw receiver: ${json['receiver']} (type: ${json['receiver']?.runtimeType})');
    
    // Debug logging for data field
    print('[AppNotification.fromJson] Raw data field: ${json['data']} (type: ${json['data']?.runtimeType})');
    if (json['data'] is Map) {
      print('[AppNotification.fromJson] Data field keys: ${(json['data'] as Map).keys.toList()}');
      // Check for rentalId in data
      final data = json['data'] as Map;
      if (data.containsKey('rentalId')) {
        print('[AppNotification.fromJson] Found rentalId in data: ${data['rentalId']} (type: ${data['rentalId'].runtimeType})');
      } else if (data.containsKey('rental_id')) {
        print('[AppNotification.fromJson] Found rental_id in data: ${data['rental_id']} (type: ${data['rental_id'].runtimeType})');
      } else if (data.containsKey('id')) {
        print('[AppNotification.fromJson] Found id in data: ${data['id']} (type: ${data['id'].runtimeType})');
      } else {
        print('[AppNotification.fromJson] No rentalId found in data field');
      }
    }

    // Handle sender conversion safely
    int? senderId;
    if (json['sender'] != null) {
      if (json['sender'] is int) {
        senderId = json['sender'];
      } else if (json['sender'] is String) {
        senderId = int.tryParse(json['sender']);
      }
    }

    // Handle receiver conversion safely
    int? receiverId;
    if (json['receiver'] != null) {
      if (json['receiver'] is int) {
        receiverId = json['receiver'];
      } else if (json['receiver'] is String) {
        receiverId = int.tryParse(json['receiver']);
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
  // Use configurable polling interval
  static Duration get defaultPollingInterval => NotificationConfig.defaultPollingInterval;
  
  NotificationCubit() : super(NotificationInitial());
  static NotificationCubit get(context) => BlocProvider.of(context);

  // Local storage for in-app notifications
  List<AppNotification> _localNotifications = [];

  // Helper method to analyze notification data
  void _analyzeNotificationData(Map<String, dynamic> json) {
    print('[Notification Analysis] Analyzing notification:');
    print('  - ID: ${json['id']}');
    print('  - Type: ${json['notification_type']}');
    print('  - Title: ${json['title']}');
    print('  - Message: ${json['message']}');
    
    // Analyze data field
    final data = json['data'];
    print('  - Data field: $data (type: ${data.runtimeType})');
    
    if (data is Map) {
      print('  - Data keys: ${data.keys.toList()}');
      
      // Check for rentalId in various possible field names
      final possibleRentalIdFields = ['rentalId', 'rental_id', 'id', 'rental', 'rentalId', 'rentalId'];
      for (final field in possibleRentalIdFields) {
        if (data.containsKey(field)) {
          final value = data[field];
          print('  - Found $field: $value (type: ${value.runtimeType})');
        }
      }
      
      // If no rentalId found, print all data for debugging
      if (!data.containsKey('rentalId') && 
          !data.containsKey('rental_id') && 
          !data.containsKey('id') && 
          !data.containsKey('rental')) {
        print('  - No rentalId found. All data: $data');
      }
    }
  }

  // Debug method to analyze all notifications of a specific type
  void analyzeNotificationsByType(String type) {
    print('[Notification Analysis] Analyzing all notifications of type: $type');
    final notifications = _localNotifications.where((n) => 
      n.type == type || n.notificationType == type
    ).toList();
    
    print('[Notification Analysis] Found ${notifications.length} notifications of type $type');
    
    for (int i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      print('[Notification Analysis] Notification $i:');
      print('  - ID: ${notification.id}');
      print('  - Type: ${notification.type}');
      print('  - NotificationType: ${notification.notificationType}');
      print('  - NavigationId: ${notification.navigationId}');
      print('  - Title: ${notification.title}');
      print('  - Message: ${notification.message}');
      print('  - Data: ${notification.data}');
      
      if (notification.data != null) {
        final data = notification.data!;
        print('  - Data keys: ${data.keys.toList()}');
        
        // Check for rentalId in various possible field names
        final possibleRentalIdFields = ['rentalId', 'rental_id', 'id', 'rental'];
        for (final field in possibleRentalIdFields) {
          if (data.containsKey(field)) {
            final value = data[field];
            print('  - Found $field: $value (type: ${value.runtimeType})');
          }
        }
        
        // Check for carDetails
        if (data.containsKey('carDetails')) {
          final carDetails = data['carDetails'] as Map<String, dynamic>?;
          if (carDetails != null) {
            print('  - Found carDetails with keys: ${carDetails.keys.toList()}');
            if (carDetails.containsKey('images')) {
              final images = carDetails['images'] as List<dynamic>?;
              print('  - Found ${images?.length ?? 0} car images');
              if (images != null && images.isNotEmpty) {
                final firstImage = images.first as Map<String, dynamic>;
                print('  - First image URL: ${firstImage['url']}');
              }
            }
          }
        }
        
        // Check for renterDetails
        if (data.containsKey('renterDetails')) {
          final renterDetails = data['renterDetails'] as Map<String, dynamic>?;
          if (renterDetails != null) {
            print('  - Found renterDetails with keys: ${renterDetails.keys.toList()}');
            print('  - Renter name: ${renterDetails['name']}');
          }
        }
      }
    }
  }

  // Debug method to analyze DEP_OWNER notifications (including PAYMENT with DEP_OWNER navigation_id)
  void analyzeDepOwnerNotifications() {
    print('[Notification Analysis] Analyzing all DEP_OWNER related notifications...');
    
    // Find notifications that are either DEP_OWNER type or PAYMENT type with DEP_OWNER navigation_id
    final depOwnerNotifications = _localNotifications.where((n) => 
      n.type == 'DEP_OWNER' || 
      n.notificationType == 'DEP_OWNER' ||
      (n.type == 'PAYMENT' && n.navigationId == 'DEP_OWNER') ||
      (n.notificationType == 'PAYMENT' && n.navigationId == 'DEP_OWNER')
    ).toList();
    
    print('[Notification Analysis] Found ${depOwnerNotifications.length} DEP_OWNER related notifications');
    
    for (int i = 0; i < depOwnerNotifications.length; i++) {
      final notification = depOwnerNotifications[i];
      print('[Notification Analysis] DEP_OWNER Notification $i:');
      print('  - ID: ${notification.id}');
      print('  - Type: ${notification.type}');
      print('  - NotificationType: ${notification.notificationType}');
      print('  - NavigationId: ${notification.navigationId}');
      print('  - Title: ${notification.title}');
      print('  - Message: ${notification.message}');
      
      if (notification.data != null) {
        final data = notification.data!;
        print('  - Data keys: ${data.keys.toList()}');
        
        // Check for rentalId
        if (data.containsKey('rentalId')) {
          final rentalId = data['rentalId'];
          print('  - ✅ Found rentalId: $rentalId (type: ${rentalId.runtimeType})');
        } else {
          print('  - ❌ No rentalId found in data');
        }
        
        // Check for carDetails
        if (data.containsKey('carDetails')) {
          final carDetails = data['carDetails'] as Map<String, dynamic>?;
          if (carDetails != null) {
            print('  - Found carDetails with keys: ${carDetails.keys.toList()}');
            if (carDetails.containsKey('images')) {
              final images = carDetails['images'] as List<dynamic>?;
              print('  - Found ${images?.length ?? 0} car images');
            }
          }
        }
      }
    }
  }

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

          // Debug: Print notification structure for analysis
          if (results.isNotEmpty) {
            print('[getAllNotifications] Found ${results.length} notifications');
            print('[getAllNotifications] First notification structure:');
            print(results.first);
            
            // Check for DEP_OWNER notifications specifically
            final depOwnerNotifications = results.where((json) => 
              json['notification_type'] == 'DEP_OWNER' || 
              json['type'] == 'DEP_OWNER'
            ).toList();
            
            if (depOwnerNotifications.isNotEmpty) {
              print('[getAllNotifications] Found ${depOwnerNotifications.length} DEP_OWNER notifications:');
              for (int i = 0; i < depOwnerNotifications.length; i++) {
                final notification = depOwnerNotifications[i];
                print('[getAllNotifications] DEP_OWNER notification $i:');
                _analyzeNotificationData(notification);
              }
            }
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
        message = 'Deposit of $amount EGP has been paid for $carBrand $carModel';
        break;
      case 'payment_completed':
        title = 'Payment Completed';
        message = 'Payment of $amount EGP has been completed for $carBrand $carModel';
        break;
      case 'refund_processed':
        title = 'Refund Processed';
        message = 'Refund of $amount EGP has been processed for $carBrand $carModel';
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

  // Fetch new notifications from API
  Future<void> fetchNewNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        final response = await ApiService().getWithToken("notifications/notifications/", token);

        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> results = data['results'] ?? [];

          // Debug: Print notification structure for analysis
          if (results.isNotEmpty) {
            print('[fetchNewNotifications] Found ${results.length} notifications');
            print('[fetchNewNotifications] First notification structure:');
            print(results.first);
            
            // Check for DEP_OWNER notifications specifically
            final depOwnerNotifications = results.where((json) => 
              json['notification_type'] == 'DEP_OWNER' || 
              json['type'] == 'DEP_OWNER'
            ).toList();
            
            if (depOwnerNotifications.isNotEmpty) {
              print('[fetchNewNotifications] Found ${depOwnerNotifications.length} DEP_OWNER notifications:');
              for (int i = 0; i < depOwnerNotifications.length; i++) {
                final notification = depOwnerNotifications[i];
                print('[fetchNewNotifications] DEP_OWNER notification $i:');
                _analyzeNotificationData(notification);
              }
            }
          }

          // Convert and update notifications
          final apiNotifications = results.map((json) {
            try {
              return AppNotification.fromJson(json);
            } catch (e) {
              print('[fetchNewNotifications] Error parsing notification: $e');
              print('[fetchNewNotifications] Problematic JSON: $json');
              rethrow;
            }
          }).toList();

          // Update local notifications
          _localNotifications = apiNotifications;
          
          if (state is NotificationLoaded) {
            emit(NotificationLoaded(_localNotifications));
          }
        }
      }
    } catch (e) {
      print('[fetchNewNotifications] Error: $e');
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

    // Navigate based on navigation_id string values
    switch (notification.navigationId) {
      case 'REQ_OWNER':
        Navigator.pushNamed(context, ScreensName.ownerTripRequestScreen, arguments: {
          'bookingRequestId': notification.id,
          'bookingData': notification.data ?? {},
        });
        break;
      case 'ACC_RENTER':
        Navigator.pushNamed(context, ScreensName.bookingSummaryScreen, arguments: notification.data);
        break;
      case 'REJ_RENTER':
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen, arguments: notification.data);
        break;
      case 'DEP_OWNER':
        Navigator.pushNamed(context, ScreensName.handoverScreen, arguments: notification.data);
        break;
      case 'OWN_RENT_HND':
        Navigator.pushNamed(context, ScreensName.renterHandoverScreen, arguments: notification.data);
        break;
      case 'REN_ONT_TRP':
        Navigator.pushNamed(context, ScreensName.renterOngoingTripScreen, arguments: notification.data);
        break;
      case 'OWN_ONT_TRP':
        Navigator.pushNamed(context, ScreensName.ownerOngoingTripScreen, arguments: notification);
        break;
      case 'LOC_GET':
        Navigator.pushNamed(context, ScreensName.liveLocationMapScreen, arguments: notification.data);
        break;
      case 'REN_DRP_HND':
        Navigator.pushNamed(context, ScreensName.renterDropOffScreen, arguments: notification.data);
        break;
      case 'OWN_DRP_HND':
        Navigator.pushNamed(context, ScreensName.ownerDropOffScreen, arguments: notification.data);
        break;
      case 'SUM_VIEW':
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen, arguments: notification.data);
        break;
      case 'NAV_HOME':
        Navigator.pushNamedAndRemoveUntil(context, ScreensName.homeScreen, (route) => false);
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
