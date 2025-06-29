import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/notification_model.dart';
import '../../../../core/services/notification_service.dart';

// Simple notification model
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        message: message,
        date: date,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props => [id, title, message, date, isRead];
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
  final List<NotificationModel> notifications;
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
  final NotificationService _notificationService = NotificationService();

  // Fetch notifications for a specific user and type
  Future<void> fetchNotificationsForUser(String userId, String type) async {
    emit(NotificationLoading());
    try {
      await for (final notifications in _notificationService.getNotificationsForUser(userId, type)) {
        emit(NotificationLoaded(notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  // Fetch all notifications for a user (both types)
  Future<void> fetchAllNotificationsForUser(String userId) async {
    emit(NotificationLoading());
    try {
      await for (final notifications in _notificationService.getAllNotificationsForUser(userId)) {
        emit(NotificationLoaded(notifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Update local state
      if (state is NotificationLoaded) {
        final currentNotifications = (state as NotificationLoaded).notifications;
        final updatedNotifications = currentNotifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        emit(NotificationLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: $e'));
    }
  }

  // Send booking notifications
  Future<void> sendBookingNotifications({
    required String renterId,
    required String ownerId,
    required String carName,
  }) async {
    try {
      await _notificationService.sendBookingNotifications(
        renterId: renterId,
        ownerId: ownerId,
        carName: carName,
      );
    } catch (e) {
      emit(NotificationError('Failed to send booking notifications: $e'));
    }
  }
} 