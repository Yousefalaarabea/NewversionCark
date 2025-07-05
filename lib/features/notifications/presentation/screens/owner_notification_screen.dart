import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/notification_cubit.dart';

class OwnerNotificationScreen extends StatelessWidget {
  const OwnerNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    final cubit = context.read<NotificationCubit>();
                    switch (value) {
                      case 'mark_all_read':
                        cubit.markAllAsRead();
                        break;
                      case 'clear_all':
                        cubit.clearAllNotifications();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read),
                          SizedBox(width: 8),
                          Text('Mark all as read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear all'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        builder: (context, state) {
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
                    onPressed: () => context.read<NotificationCubit>().getAllNotifications(),
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

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationCard(context, notification);
              },
            );
          }
          return const SizedBox.shrink();
        },
        listener: (BuildContext context, NotificationState state) {
          // Handle any side effects here if needed
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () {
          _handleNotificationTap(context, notification);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: ListTile(
          contentPadding: EdgeInsets.all(16.r),
          leading: Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.grey[200]
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: notification.isRead
                  ? Colors.grey[600]
                  : Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
              color: notification.isRead
                  ? Colors.grey[700]
                  : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                notification.message,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12.sp,
                    color: Colors.grey[500],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatTimestamp(notification.date),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _getTypeDisplayName(notification.type).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(notification.type),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Handle navigation based on notification type and data
    switch (notification.navigationId) {
      case 'REQ_OWNER':
        // Navigate to booking request screen
        Navigator.pushNamed(
          context,
          ScreensName.ownerTripRequestScreen,
          arguments: {
            'bookingRequestId': notification.data?['bookingRequestId'] ?? '',
            'bookingData': notification.data ?? {},
          },
        );
        break;

      // case 'ACC_RENTER':
      // // Navigate to booking request screen
      //   Navigator.pushNamed(
      //     context,
      //     ScreensName.ownerTripRequestScreen,
      //     arguments: {
      //       'bookingRequestId': notification.data?['bookingRequestId'] ?? '',
      //       'bookingData': notification.data ?? {},
      //     },
      //   );
      //   break;


      case 'deposit_paid':
      case 'handover_started':
        // Navigate to handover screen
        Navigator.pushNamed(
          context,
          ScreensName.handoverScreen,
          arguments: notification.data,
        );
        break;
      case 'handover_completed':
      case 'trip_started':
        // Navigate to ongoing trip screen
        Navigator.pushNamed(
          context,
          ScreensName.ownerOngoingTripScreen,
          arguments: notification.data,
        );
        break;
      default:
        // Default behavior - just mark as read
        break;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_request':
      case 'booking_accepted':
      case 'booking_declined':
        return Icons.car_rental;
      case 'deposit_paid':
      case 'payment_completed':
      case 'refund_processed':
        return Icons.payment;
      case 'handover_started':
      case 'handover_completed':
      case 'handover_cancelled':
        return Icons.swap_horiz;
      case 'trip_started':
      case 'trip_completed':
      case 'trip_cancelled':
        return Icons.directions_car;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'booking_request':
        return Colors.orange;
      case 'booking_accepted':
        return Colors.green;
      case 'booking_declined':
        return Colors.red;
      case 'deposit_paid':
      case 'payment_completed':
        return Colors.blue;
      case 'refund_processed':
        return Colors.purple;
      case 'handover_started':
      case 'handover_completed':
        return Colors.teal;
      case 'handover_cancelled':
        return Colors.red;
      case 'trip_started':
      case 'trip_completed':
        return Colors.indigo;
      case 'trip_cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'booking_request':
        return 'Booking Request';
      case 'booking_accepted':
        return 'Booking Accepted';
      case 'booking_declined':
        return 'Booking Declined';
      case 'deposit_paid':
        return 'Deposit Paid';
      case 'payment_completed':
        return 'Payment Completed';
      case 'refund_processed':
        return 'Refund Processed';
      case 'handover_started':
        return 'Handover Started';
      case 'handover_completed':
        return 'Handover Completed';
      case 'handover_cancelled':
        return 'Handover Cancelled';
      case 'trip_started':
        return 'Trip Started';
      case 'trip_completed':
        return 'Trip Completed';
      case 'trip_cancelled':
        return 'Trip Cancelled';
      default:
        return 'General';
    }
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
