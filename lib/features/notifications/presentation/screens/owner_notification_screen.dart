import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/services/notification_service.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerNotificationScreen extends StatelessWidget {
  const OwnerNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().userModel;
    final userId = user?.id ?? '1';
    print('###################################Current userId for Notification Screen: $userId'); //

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
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
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when you have updates',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp?.toDate();
              final isRead = data['read'] ?? false;
              final notificationType = data['type'] ?? 'general';
              final notificationTypeSpecific = data['notification_type'] ?? '';

              String formattedTime = '';
              if (date != null) {
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
              }

              // Choose icon based on notification type
              IconData notificationIcon;
              Color iconColor;

              switch (notificationType) {
                case 'booking':
                  notificationIcon = Icons.calendar_today;
                  iconColor = Colors.blue;
                  break;
                case 'payment':
                  notificationIcon = Icons.payment;
                  iconColor = Colors.green;
                  break;
                case 'car':
                  notificationIcon = Icons.directions_car;
                  iconColor = Colors.orange;
                  break;
                default:
                  notificationIcon = Icons.notifications;
                  iconColor = Colors.grey;
              }

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                color: isRead ? Colors.grey.shade50 : Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isRead ? Colors.grey.shade300 : iconColor,
                        child: Icon(
                          notificationIcon,
                          color: isRead ? Colors.grey.shade600 : Colors.white,
                        ),
                      ),
                      title: Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['body'] ?? ''),
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
                        // Mark as read
                        FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(docs[index].id)
                            .update({'read': true});
                      },
                    ),
                    // Show action buttons for booking requests
                    if (notificationType == 'owner' && 
                        notificationTypeSpecific == 'car_booked' && 
                        !isRead)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _acceptBookingRequest(context, data, docs[index].id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Accept'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _declineBookingRequest(context, data, docs[index].id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Decline'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Show action button for handover notifications
                    if (notificationType == 'owner' && 
                        notificationTypeSpecific == 'handover_ready' && 
                        !isRead)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToHandover(context, docs[index].id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Proceed to Handover'),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptBookingRequest(BuildContext context, Map<String, dynamic> data, String notificationId) async {
    try {
      // Extract booking data from the notification
      final bookingData = data['booking_data'] as Map<String, dynamic>?;
      if (bookingData == null) {
        throw Exception('Booking data not found in notification');
      }

      final renterId = bookingData['renterId'] as String?;
      final renterName = bookingData['renterName'] as String? ?? 'A renter';
      final carBrand = bookingData['carBrand'] as String? ?? '';
      final carModel = bookingData['carModel'] as String? ?? '';
      final carId = bookingData['carId'] as String?;
      final totalPrice = bookingData['totalPrice'] as double? ?? 0.0;
      
      // Get current user (owner)
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.userModel;
      
      if (currentUser == null) {
        throw Exception('User not found');
      }

      if (renterId == null) {
        throw Exception('Renter ID not found in booking data');
      }

      // Update booking request status in Firestore
      final bookingRequestsQuery = await FirebaseFirestore.instance
          .collection('booking_requests')
          .where('renterId', isEqualTo: renterId)
          .where('carId', isEqualTo: carId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (bookingRequestsQuery.docs.isNotEmpty) {
        final bookingRequestId = bookingRequestsQuery.docs.first.id;
        await FirebaseFirestore.instance
            .collection('booking_requests')
            .doc(bookingRequestId)
            .update({
          'status': 'accepted',
          'acceptedAt': DateTime.now().toIso8601String(),
          'ownerId': currentUser.id,
        });
      }

      // Send acceptance notification to renter
      await NotificationService().sendBookingAcceptanceNotification(
        renterId: renterId,
        ownerName: '${currentUser.firstName} ${currentUser.lastName}',
        carBrand: carBrand,
        carModel: carModel,
      );

      // Mark notification as read and update status
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'status': 'accepted',
      });

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking request accepted! Notification sent to $renterName.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error accepting booking request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting booking request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _declineBookingRequest(BuildContext context, Map<String, dynamic> data, String notificationId) async {
    try {
      // Extract booking data from the notification
      final bookingData = data['booking_data'] as Map<String, dynamic>?;
      if (bookingData != null) {
        final renterId = bookingData['renterId'] as String?;
        final carId = bookingData['carId'] as String?;
        
        if (renterId != null && carId != null) {
          // Update booking request status in Firestore
          final bookingRequestsQuery = await FirebaseFirestore.instance
              .collection('booking_requests')
              .where('renterId', isEqualTo: renterId)
              .where('carId', isEqualTo: carId)
              .where('status', isEqualTo: 'pending')
              .get();

          if (bookingRequestsQuery.docs.isNotEmpty) {
            final bookingRequestId = bookingRequestsQuery.docs.first.id;
            await FirebaseFirestore.instance
                .collection('booking_requests')
                .doc(bookingRequestId)
                .update({
              'status': 'declined',
              'declinedAt': DateTime.now().toIso8601String(),
            });
          }

          // Send decline notification to renter
          await NotificationService().sendNotificationToUser(
            userId: renterId,
            title: 'Booking Request Declined',
            body: 'Your booking request has been declined by the car owner.',
            type: 'renter',
            notificationType: 'booking_declined',
            bookingData: bookingData,
          );
        }
      }

      // Mark notification as read and update status
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'status': 'declined',
      });

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request declined.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error declining booking request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining booking request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToHandover(BuildContext context, String notificationId) async {
    try {
      // Mark notification as read
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Navigate to handover screen
      if (context.mounted) {
        Navigator.pushNamed(context, ScreensName.handoverScreen);
      }
    } catch (e) {
      print('Error navigating to handover: $e');
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
}
