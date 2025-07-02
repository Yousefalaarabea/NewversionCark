import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/models/user_model.dart';

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
  UserModel? _renterInfo;

  @override
  void initState() {
    super.initState();
    _loadRenterInfo();
  }

  Future<void> _loadRenterInfo() async {
    try {
      final renterId = widget.bookingData['renterId'] as String?;
      if (renterId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(renterId)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            _renterInfo = UserModel.fromJson(userDoc.data()!);
          });
        }
      }
    } catch (e) {
      print('Error loading renter info: $e');
    }
  }

  Future<void> _acceptRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.userModel;
      
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Update booking request status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(widget.bookingRequestId)
          .update({
        'status': 'accepted',
        'acceptedAt': DateTime.now().toIso8601String(),
        'ownerId': currentUser.id,
      });

      // Send notification to renter
      final renterId = widget.bookingData['renterId'] as String?;
      final renterName = widget.bookingData['renterName'] as String? ?? 'A renter';
      final carBrand = widget.bookingData['carBrand'] as String? ?? '';
      final carModel = widget.bookingData['carModel'] as String? ?? '';

      if (renterId != null) {
        await NotificationService().sendBookingAcceptanceNotification(
          renterId: renterId,
          ownerName: '${currentUser.firstName} ${currentUser.lastName}',
          carBrand: carBrand,
          carModel: carModel,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request accepted! Notification sent to renter.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _rejectRequest() async {
    final reason = await _showRejectionDialog();
    if (reason == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(widget.bookingRequestId)
          .update({
        'status': 'declined',
        'declinedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reason,
      });

      final renterId = widget.bookingData['renterId'] as String?;
      if (renterId != null) {
        await NotificationService().sendNotificationToUser(
          userId: renterId,
          title: 'Booking Request Declined',
          body: 'Your booking request has been declined by the car owner.',
          type: 'renter',
          notificationType: 'booking_declined',
          bookingData: widget.bookingData,
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                  _buildRenterInfoCard(theme),
                  SizedBox(height: 16.h),
                  _buildCarDetailsCard(theme),
                  SizedBox(height: 16.h),
                  _buildLocationAndDatesCard(theme),
                  SizedBox(height: 16.h),
                  _buildPaymentDetailsCard(theme),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
      bottomNavigationBar: _buildActionButtons(theme),
    );
  }

  Widget _buildRenterInfoCard(ThemeData theme) {
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
                        _renterInfo != null 
                            ? '${_renterInfo!.firstName} ${_renterInfo!.lastName}'
                            : widget.bookingData['renterName'] ?? 'Unknown Renter',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (_renterInfo != null) ...[
                        Text(
                          _renterInfo!.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _renterInfo!.phoneNumber,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

  Widget _buildCarDetailsCard(ThemeData theme) {
    final carBrand = widget.bookingData['carBrand'] as String? ?? '';
    final carModel = widget.bookingData['carModel'] as String? ?? '';

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
              value: carBrand,
              iconColor: Colors.blue,
            ),
            SizedBox(height: 12.h),
            
            _buildDetailRow(
              icon: Icons.car_rental,
              title: 'Car Model',
              value: carModel,
              iconColor: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndDatesCard(ThemeData theme) {
    final pickupStation = widget.bookingData['pickupStation'] as String? ?? '';
    final returnStation = widget.bookingData['returnStation'] as String? ?? '';
    final dateRange = widget.bookingData['dateRange'] as String? ?? '';
    
    // Parse date range to extract start and end dates
    String startDate = 'Unknown';
    String endDate = 'Unknown';
    
    try {
      if (dateRange.contains(' - ')) {
        final dates = dateRange.split(' - ');
        if (dates.length >= 2) {
          startDate = dates[0].trim();
          endDate = dates[1].trim();
        }
      } else {
        startDate = dateRange;
        endDate = dateRange;
      }
    } catch (e) {
      print('Error parsing date range: $e');
    }

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
                        pickupStation,
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
                        returnStation,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(ThemeData theme) {
    final totalPrice = widget.bookingData['totalPrice'] as double? ?? 0.0;
    final paymentMethod = widget.bookingData['paymentMethod'] as String? ?? 'Unknown';

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
              title: 'Total Price',
              value: '\$${totalPrice.toStringAsFixed(2)}',
              iconColor: Colors.green,
            ),
            SizedBox(height: 12.h),
            
            _buildDetailRow(
              icon: Icons.account_balance_wallet,
              title: 'Payment Method',
              value: paymentMethod,
              iconColor: Colors.purple,
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