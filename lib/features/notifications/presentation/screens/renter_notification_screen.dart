import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';

import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../cars/presentation/models/car_rental_options.dart';
import '../../../home/presentation/model/car_model.dart';


class RenterNotificationScreen extends StatelessWidget {
  const RenterNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().userModel;
    final userId = user?.id ?? '1';
    return Scaffold(
      appBar: AppBar(title: const Text('Renter Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('type', isEqualTo: 'renter')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
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
              final notificationType = data['notification_type'] ?? '';

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

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                color: isRead ? Colors.grey.shade50 : Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isRead ? Colors.grey.shade300 : Colors.blue,
                        child: Icon(
                          _getNotificationIcon(notificationType),
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
                    // Show action button for booking acceptance notifications
                    if (notificationType == 'booking_accepted' && !isRead)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToDepositPayment(context, data, docs[index].id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Pay Deposit'),
                          ),
                        ),
                      ),
                    // Show action button for handover notifications
                    if (notificationType == 'handover' && !isRead)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToRenterHandover(context, docs[index].id),
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

  Future<void> _navigateToRenterHandover(BuildContext context, String notificationId) async {
    try {
      // Mark notification as read
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

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

  Future<void> _navigateToDepositPayment(BuildContext context, Map<String, dynamic> data, String notificationId) async {
    try {
      // Extract booking data from the notification
      final bookingData = data['booking_data'] as Map<String, dynamic>?;
      if (bookingData == null) {
        throw Exception('Booking data not found in notification');
      }

      // Mark notification as read
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Create car model from booking data for deposit payment screen
      final car = CarModel(
        ownerId: bookingData['ownerId'] ?? '',
        id: int.tryParse(bookingData['carId'].toString()) ?? 0,
        model: bookingData['carModel'] ?? '',
        brand: bookingData['carBrand'] ?? '',
        carType: bookingData['carType'] ?? 'Sedan',
        carCategory: bookingData['carCategory'] ?? 'Standard',
        plateNumber: bookingData['plateNumber'] ?? '',
        year: bookingData['year'] ?? 2023,
        color: bookingData['color'] ?? 'Black',
        seatingCapacity: bookingData['seatingCapacity'] ?? 5,
        transmissionType: bookingData['transmissionType'] ?? 'Automatic',
        fuelType: bookingData['fuelType'] ?? 'Gasoline',
        currentOdometerReading: bookingData['currentOdometerReading'] ?? 0,
        availability: true,
        currentStatus: 'Available',
        approvalStatus: true,
        rentalOptions: RentalOptions(
          availableWithDriver: false,
          availableWithoutDriver: true,
          dailyRentalPrice: null,
        ),
      );

      // Navigate to deposit payment screen
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          ScreensName.depositPaymentScreen,
          arguments: {
            'car': car,
            'totalPrice': bookingData['totalPrice']?.toDouble() ?? 0.0,
            'bookingData': bookingData,
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
}