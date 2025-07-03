import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/notification_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().getAllNotifications();
    });
  }

  void _addTestNotifications() {
    final cubit = context.read<NotificationCubit>();
    
    // Add some test notifications
    cubit.sendBookingNotification(
      renterName: 'John Doe',
      carBrand: 'Toyota',
      carModel: 'Camry',
      ownerId: 'owner_123',
      renterId: 'renter_456',
      type: 'booking_request',
    );
    
    cubit.sendPaymentNotification(
      amount: '500.00',
      carBrand: 'BMW',
      carModel: 'X5',
      type: 'deposit_paid',
    );
    
    cubit.sendHandoverNotification(
      carBrand: 'Mercedes',
      carModel: 'C-Class',
      type: 'handover_started',
      userName: 'Jane Smith',
    );
    
    cubit.sendTripNotification(
      carBrand: 'Audi',
      carModel: 'A4',
      type: 'trip_started',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Test button for adding sample notifications
          IconButton(
            onPressed: _addTestNotifications,
            icon: const Icon(Icons.add),
            tooltip: 'Add Test Notifications',
          ),
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addTestNotifications,
                      child: const Text('Add Test Notifications'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationCard(notification);
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

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Mark as read when tapped
          context.read<NotificationCubit>().markAsRead(notification.id);
          
          // Handle navigation based on notification type
          _handleNotificationTap(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.grey[200]
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: notification.isRead
                  ? Colors.grey[600]
                  : Theme.of(context).colorScheme.primary,
              size: 24,
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
              const SizedBox(height: 4),
              Text(
                notification.message,
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
                    _formatTimestamp(notification.date),
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
                          _getTypeColor(notification.type)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeDisplayName(notification.type).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
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

  void _handleNotificationTap(AppNotification notification) {
    // Handle navigation based on notification type and data
    switch (notification.type) {
      case 'booking_request':
      case 'booking_accepted':
      case 'booking_declined':
        // Navigate to booking details or booking history
        break;
      case 'deposit_paid':
      case 'payment_completed':
        // Navigate to payment details
        break;
      case 'handover_started':
      case 'handover_completed':
        // Navigate to handover screen
        break;
      case 'trip_started':
      case 'trip_completed':
        // Navigate to trip details
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
