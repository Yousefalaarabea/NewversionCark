import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';

import '../../../home/presentation/model/car_model.dart';
import '../cubits/notification_cubit.dart';

class RenterNotificationScreen extends StatelessWidget {
  const RenterNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Renter Notifications')),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification.isRead;
                final notificationType = notification.type;
                final date = notification.date;
                String formattedTime = '';
                final now = DateTime.now();
                final difference = now.difference(date);
                if (difference.inDays > 0) {
                  formattedTime = '${difference.inDays}d ago';
                } else if (difference.inHours > 0) {
                  formattedTime = '${difference.inHours}h ago';
                } else if (difference.inMinutes > 0) {
                  formattedTime = '${difference.inMinutes}m ago';
                } else {
                  formattedTime = 'Just now';
                }
                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  color: isRead ? Colors.grey.shade50 : Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isRead ? Colors.grey.shade300 : Colors.blue,
                          child: Icon(
                            _getNotificationIcon(notificationType),
                            color: isRead ? Colors.grey.shade600 : Colors.white,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.message),
                            SizedBox(height: 4.h),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _handleNotificationTap(context, notification);
                        },
                      ),
                      // Show action button for booking acceptance notifications
                      if (notificationType == 'booking_accepted' && !isRead)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _navigateToDepositPayment(
                                  context,
                                  notification.data ?? {},
                                  notification.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(''
                                  'Pay Deposit'),
                            ),
                          ),
                        ),
                      // Show action button for handover notifications
                      if (notificationType == 'handover' && !isRead)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _navigateToRenterHandover(
                                  context, notification.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Proceed to Handover'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  IconData _getNotificationIcon(String notificationType) {
    switch (notificationType) {
      case 'booking_accepted':
        return Icons.check_circle;
      case 'handover':
        return Icons.handshake;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _navigateToRenterHandover(
      BuildContext context, String notificationId) async {
    try {
      // Mark notification as read
      context.read<NotificationCubit>().markAsRead(notificationId);

      // Navigate to renter handover screen
      if (context.mounted) {
        Navigator.pushNamed(context, ScreensName.renterHandoverScreen);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to handover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToDepositPayment(BuildContext context,
      Map<String, dynamic> data, String notificationId) async {
    try {
      // Mark notification as read
      context.read<NotificationCubit>().markAsRead(notificationId);

      // Navigate to deposit payment screen with new format
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          ScreensName.paymentMethodsScreen,
          arguments: {
            'bookingRequestId': notificationId,
            'bookingData': data,
          },
        );
      }
    } catch (e) {
      print('Error navigating to deposit payment: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to deposit payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // أضف دالة موحدة للتنقل بناءً على نوع الإشعار
  void _handleNotificationTap(
      BuildContext context, AppNotification notification) {
    final notificationType = notification.type;
    switch (notificationType) {
      case 'booking_accepted':
        _navigateToDepositPayment(
            context, notification.data ?? {}, notification.id);
        break;
      case 'handover':
        _navigateToRenterHandover(context, notification.id);
        break;
      // أضف أنواع إشعارات أخرى هنا حسب الحاجة
      default:
        // فقط علمه كمقروء
        context.read<NotificationCubit>().markAsRead(notification.id);
        break;
    }
  }
}
