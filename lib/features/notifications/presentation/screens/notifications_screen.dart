import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/notification_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationCubit notificationCubit = NotificationCubit.get(context);
    notificationCubit.getAllNotifications();
    // _loadNotifications();
  }

  // void _loadNotifications() {
  //   final authCubit = context.read<AuthCubit>();
  //   final currentUser = authCubit.userModel;
  //
  //   if (currentUser != null) {
  //     final userId = currentUser.id.toString();
  //     // Load all notifications for the current user
  //     context.read<NotificationCubit>().getAllNotifications();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        builder: (context, state) {
          NotificationCubit notificationCubit = NotificationCubit.get(context);
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: notificationCubit.getAllNotifications,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ll see notifications here when you have updates',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (notificationCubit.notificationModel == null) {
              return const Text('No items returned');
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  // final notification = state.notifications[index];
                  return _buildNotificationCard(notificationCubit.notificationModel!, index);
                },
              );
            }
          }
          return const SizedBox.shrink();
        },
        listener: (BuildContext context, NotificationState state) {},
      ),
    );
  }

  Widget _buildNotificationCard(NewNotificationModel notification, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.results![index].isRead!
                ? Colors.grey[200]
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            _getNotificationIcon(notification.results![index].typeDisplay!),
            color: notification.results![index].isRead!
                ? Colors.grey[600]
                : Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          notification.results![index].title!,
          style: TextStyle(
            fontWeight: notification.results![index].isRead!
                ? FontWeight.normal
                : FontWeight.bold,
            color: notification.results![index].isRead!
                ? Colors.grey[700]
                : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.results![index].message!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(notification.results![index].timeAgo!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        _getTypeColor(notification.results![index].typeDisplay!)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.results![index].typeDisplay!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(
                          notification.results![index].typeDisplay!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // if (!notification.results![index].isRead!) {
          //   context.read<NotificationCubit>().markAsRead(notification.results![index].id!);
          // }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'renter':
        return Icons.directions_car;
      case 'owner':
        return Icons.person;
      case 'booking':
        return Icons.calendar_today;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'renter':
        return Colors.blue;
      case 'owner':
        return Colors.green;
      case 'booking':
        return Colors.orange;
      case 'payment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // String _formatTimestamp(DateTime timestamp) {
  //   final now = DateTime.now();
  //   final difference = now.difference(timestamp);
  //
  //   if (difference.inDays > 0) {
  //     return '${difference.inDays}d ago';
  //   } else if (difference.inHours > 0) {
  //     return '${difference.inHours}h ago';
  //   } else if (difference.inMinutes > 0) {
  //     return '${difference.inMinutes}m ago';
  //   } else {
  //     return 'Just now';
  //   }
  // }
  String _formatTimestamp(String createdAt) {
    try {
      final timestamp =
          DateTime.parse(createdAt).toLocal(); // تحويل للتوقيت المحلي لو حابة
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
