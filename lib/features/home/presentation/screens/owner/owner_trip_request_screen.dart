// Example notification payload required for this screen:
// {
//   "id": "f71a12a9-eb89-4bc1-a245-a6f6c0129005",
//   "sender": 2,
//   "sender_email": "ahmed5@example.com",
//   "receiver": 2,
//   "receiver_email": "ahmed5@example.com",
//   "title": "New Booking Request",
//   "message": "Ahmed Ali has requested to rent your Toyota Toyota Corolla",
//   "notification_type": "RENTAL",
//   "type_display": "حجز",
//   "priority": "HIGH",
//   "priority_display": "عالية",
//   "data": {
//       "renterId": 2,
//       "carId": 1,
//       "status": "PendingOwnerConfirmation",
//       "rentalId": 20,
//       "startDate": "2025-06-17T00:00:00+00:00",
//       "endDate": "2025-06-20T00:00:00+00:00",
//       "pickupAddress": "Tahrir Square, Cairo",
//       "dropoffAddress": "Pyramids of Giza",
//       "renterName": "Ahmed Ali",
//       "carName": "Toyota Toyota Corolla",
//       "dailyPrice": 100.0,
//       "totalDays": 4,
//       "totalAmount": 496.6,
//       "depositAmount": 74.49
//   },
//   "navigation_id": "REQ_OWNER",
//   "is_read": true,
//   "read_at": "2025-07-05T00:21:04.399980Z",
//   "created_at": "2025-07-05T00:20:24.663694Z",
//   "time_ago": "منذ 5 ساعة"
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';
import 'package:test_cark/core/booking_service.dart';

class OwnerTripRequestScreen extends StatefulWidget {
  final String bookingRequestId;
  final Map<String, dynamic> bookingData;

  const OwnerTripRequestScreen({
    super.key,
    required this.bookingRequestId,
    required this.bookingData,
  });

  @override
  State<OwnerTripRequestScreen> createState() => _OwnerTripRequestScreenState();
}

class _OwnerTripRequestScreenState extends State<OwnerTripRequestScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Debug logs
    print('OwnerTripRequestScreen: initState called');
    print('OwnerTripRequestScreen: bookingRequestId: ${widget.bookingRequestId}');
    print('OwnerTripRequestScreen: bookingData: ${widget.bookingData}');
  }

  // Helper function to format date from ISO string
  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Helper function to extract car brand and model from carName
  Map<String, String> _extractCarInfo(String? carName) {
    if (carName == null || carName.isEmpty) {
      return {'brand': '', 'model': ''};
    }
    
    final parts = carName.split(' ');
    if (parts.length >= 2) {
      return {
        'brand': parts[0],
        'model': parts.sublist(1).join(' '),
      };
    } else {
      return {'brand': carName, 'model': ''};
    }
  }

  Future<void> _acceptRequest() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final rentalId = widget.bookingData['rentalId'];
      if (rentalId == null) throw Exception('rentalId not found in bookingData');
      final bookingService = BookingService();
      final result = await bookingService.confirmBooking(int.parse(rentalId.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _rejectRequest() async {
    final reason = await _showRejectionDialog();
    if (reason == null) return;

    setState(() { _isLoading = true; });
    try {
      final renterId = widget.bookingData['renterId']?.toString();
      if (renterId != null) {
        context.read<NotificationCubit>().sendBookingNotification(
          renterName: widget.bookingData['renterName'] as String? ?? '',
          carBrand: widget.bookingData['carName'] as String? ?? '',
          carModel: '',
          ownerId: '',
          renterId: renterId,
          type: 'booking_declined',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request declined. Notification sent to renter.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<String?> _showRejectionDialog() async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this request (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.bookingData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Request'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRenterInfoCard(theme, data),
                  SizedBox(height: 16.h),
                  _buildCarDetailsCard(theme, data),
                  SizedBox(height: 16.h),
                  _buildLocationAndDatesCard(theme, data),
                  SizedBox(height: 16.h),
                  _buildPaymentDetailsCard(theme, data),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
      bottomNavigationBar: _buildActionButtons(theme),
    );
  }

  Widget _buildRenterInfoCard(ThemeData theme, Map<String, dynamic> data) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.primaryColor, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Renter Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 30.sp,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['renterName'] ?? 'Unknown Renter',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (data['sender_email'] != null)
                        Text(
                          data['sender_email'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetailsCard(ThemeData theme, Map<String, dynamic> data) {
    final carName = data['carName'] as String? ?? '';
    final carInfo = _extractCarInfo(carName);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Car Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              icon: Icons.directions_car,
              title: 'Car Brand',
              value: carInfo['brand'] ?? '',
              iconColor: Colors.blue,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.car_rental,
              title: 'Car Model',
              value: carInfo['model'] ?? '',
              iconColor: Colors.indigo,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.attach_money,
              title: 'Daily Price',
              value: '${(data['dailyPrice'] as double? ?? 0.0).toStringAsFixed(2)} EGP',
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndDatesCard(ThemeData theme, Map<String, dynamic> data) {
    final pickupAddress = data['pickupAddress'] as String? ?? '';
    final dropoffAddress = data['dropoffAddress'] as String? ?? '';
    final startDate = _formatDate(data['startDate'] as String?);
    final endDate = _formatDate(data['endDate'] as String?);
    final totalDays = data['totalDays'] as int? ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Location & Dates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Pickup location with start date
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        pickupAddress,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      startDate,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Return location with end date
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.red, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drop-off Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        dropoffAddress,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Return Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      endDate,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Total days
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.orange, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  'Total Days: ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$totalDays days',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(ThemeData theme, Map<String, dynamic> data) {
    final totalAmount = data['totalAmount'] as double? ?? 0.0;
    final depositAmount = data['depositAmount'] as double? ?? 0.0;
    final dailyPrice = data['dailyPrice'] as double? ?? 0.0;
    final totalDays = data['totalDays'] as int? ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.purple, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Payment Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              icon: Icons.attach_money,
              title: 'Daily Price',
              value: '${dailyPrice.toStringAsFixed(2)} EGP',
              iconColor: Colors.blue,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'Total Days',
              value: '$totalDays days',
              iconColor: Colors.orange,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.account_balance_wallet,
              title: 'Deposit Amount',
              value: '${depositAmount.toStringAsFixed(2)} EGP',
              iconColor: Colors.amber,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.payment,
              title: 'Total Amount',
              value: '${totalAmount.toStringAsFixed(2)} EGP',
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _rejectRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _acceptRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 