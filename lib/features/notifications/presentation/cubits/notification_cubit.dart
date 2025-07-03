import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/auth/presentation/models/user_model.dart';
import '../../../../core/api_service.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../models/notification_model.dart';

// Simple in-app notification model
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    required this.type,
    this.data,
  });

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
      );

  @override
  List<Object?> get props => [id, title, message, date, isRead, type, data];
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
        final response = await ApiService().getWithToken("notifications/", token);
        if (response.statusCode == 200) {
          final notificationModel = NewNotificationModel.fromJson(response.data);
          
          // Convert API notifications to AppNotification format
          final apiNotifications = notificationModel.results?.map((result) => 
            AppNotification(
              id: result.id ?? '',
              title: result.title ?? '',
              message: result.message ?? '',
              date: DateTime.tryParse(result.createdAt ?? '') ?? DateTime.now(),
              isRead: result.isRead ?? false,
              type: result.notificationType ?? 'general',
              data: result.data?.toJson(),
            )
          ).toList() ?? [];
          
          // Combine API notifications with local notifications
          _localNotifications = [...apiNotifications, ..._localNotifications];
        }
      }
      
      emit(NotificationLoaded(_localNotifications));
    } catch (e) {
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
  void markAsRead(String notificationId) {
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

  // Mark all notifications as read
  void markAllAsRead() {
    _localNotifications = _localNotifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();
    
    if (state is NotificationLoaded) {
      emit(NotificationLoaded(_localNotifications));
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
    
    addNotification(
      title: title,
      message: message,
      type: type,
      data: {
        'renterName': renterName,
        'carBrand': carBrand,
        'carModel': carModel,
        'ownerId': ownerId,
        'renterId': renterId,
      },
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
} 