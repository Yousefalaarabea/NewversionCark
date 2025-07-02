import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../auth/presentation/models/user_model.dart';
import '../../model/car_model.dart';
import '../../model/trip_details_model.dart';

class RenterOngoingTripScreen extends StatefulWidget {
  final TripDetailsModel tripDetails;

  const RenterOngoingTripScreen({
    super.key,
    required this.tripDetails,
  });

  @override
  State<RenterOngoingTripScreen> createState() => _RenterOngoingTripScreenState();
}

class _RenterOngoingTripScreenState extends State<RenterOngoingTripScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Trip'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTripOverviewCard(theme),
                  SizedBox(height: 16.h),
                  _buildLocationInfoCard(theme),
                  SizedBox(height: 16.h),
                  _buildOwnerInfoCard(theme),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildTripOverviewCard(ThemeData theme) {
    final car = widget.tripDetails.car;
    final startDate = widget.tripDetails.startDate;
    final endDate = widget.tripDetails.endDate;
    final totalPrice = widget.tripDetails.totalPrice;
    final paymentMethod = widget.tripDetails.paymentMethod;

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
                Icon(Icons.directions_car, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Trip Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Car info with image
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey[200],
                  ),
                  child: car.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            car.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.directions_car,
                                size: 40.sp,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.directions_car,
                          size: 40.sp,
                          color: Colors.grey[400],
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.brand} ${car.model}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Year: ${car.year}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Rental duration
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'Rental Duration',
              value: '${_formatDate(startDate)} - ${_formatDate(endDate)}',
              iconColor: Colors.blue,
            ),
            SizedBox(height: 12.h),
            
            // Payment method
            _buildDetailRow(
              icon: Icons.account_balance_wallet,
              title: 'Payment Method',
              value: paymentMethod,
              iconColor: Colors.purple,
            ),
            SizedBox(height: 12.h),
            
            // Total price
            _buildDetailRow(
              icon: Icons.attach_money,
              title: 'Total Price',
              value: '\$${totalPrice.toStringAsFixed(2)}',
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard(ThemeData theme) {
    final pickupLocation = widget.tripDetails.pickupLocation;
    final dropoffLocation = widget.tripDetails.dropoffLocation;

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
                  'Trip Locations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Pickup location
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 20.sp,
                  ),
                ),
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
                        pickupLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Drop-off location
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Colors.red,
                    size: 20.sp,
                  ),
                ),
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
                        dropoffLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Remaining time (optional)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.orange,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Trip ends in ${_calculateRemainingTime()}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfoCard(ThemeData theme) {
    final ownerName = widget.tripDetails.ownerName;

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
                Icon(Icons.person, color: Colors.indigo, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Car Owner',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.indigo.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 30.sp,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Car Owner',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // IconButton(
                //   onPressed: () {
                //     // TODO: Implement contact owner functionality
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Contact feature coming soon!'),
                //         backgroundColor: Colors.blue,
                //       ),
                //     );
                //   },
                //   icon: Icon(
                //     Icons.phone,
                //     color: Colors.indigo,
                //     size: 24.sp,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Support button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showSupportDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                icon: Icon(Icons.support_agent, size: 20.sp),
                label: Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            
            // Confirm drop-off button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmDropOffDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Confirm Drop-Off',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateRemainingTime() {
    final now = DateTime.now();
    final endDate = widget.tripDetails.endDate;
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      return '0 hours';
    }
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      return '$days days, $remainingHours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.blue, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with your trip?',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Text(
              'Our support team is available 24/7 to assist you with any issues during your trip.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  '+1 (555) 123-4567',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.email, color: Colors.blue, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'support@cark.com',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDropOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('Confirm Drop-Off'),
          ],
        ),
        content: Text(
          'Are you sure you want to end the trip? This action cannot be undone.',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDropOffScreen();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToDropOffScreen() {
    // Navigate to RenterDropOffScreen with required arguments
    Navigator.pushNamed(
      context,
      ScreensName.renterDropOffScreen,
      arguments: {
        'tripId': 'trip_${DateTime.now().millisecondsSinceEpoch}', // Generate trip ID
        'carId': widget.tripDetails.car.id.toString(),
        'renterId': 'renter_001', // TODO: Get from auth
        'ownerId': 'owner_001', // TODO: Get from car data
        'paymentMethod': widget.tripDetails.paymentMethod,
      },
    );
  }
} 