import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/presentation/widgets/profile_custom_widgets/document_upload_flow.dart';
import '../../model/car_model.dart';
import '../../cubit/car_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cark/features/home/presentation/screens/booking_screens/deposit_input_screen.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingSummaryScreen extends StatefulWidget {
  final CarModel car;
  final double totalPrice;

  const BookingSummaryScreen(
      {super.key, required this.car, required this.totalPrice});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(tr("booking_confirmation"),
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarDetails(),
            SizedBox(height: 24.h),
            _buildConditions(),
            SizedBox(height: 24.h),
            _buildBookingOverview(),
            SizedBox(height: 32.h),
            _buildAgreementSection(),
            SizedBox(height: 40.h),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.car.brand} ${widget.car.model}',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 8.h),
            Text(
              '${tr("or_similar")} | ${widget.car.carType}',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr("conditions"),
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr("maximum_deductible"),
                    style: TextStyle(
                        fontSize: 15.sp, color: Colors.grey.shade700)),
                Text(tr("up_to_800"),
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(tr("included_no_extra_cost"),
                    style: TextStyle(fontSize: 15.sp, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingOverview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr("booking_overview"),
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 16.h),
            _buildOverviewItem(Icons.check_circle, tr("third_party_insurance"),
                AppColors.primary),
            _buildOverviewItem(Icons.check_circle,
                tr("collision_damage_waiver"), AppColors.primary),
            _buildOverviewItem(
                Icons.check_circle, tr("theft_protection"), AppColors.primary),
            _buildOverviewItem(
                Icons.check_circle, tr("km_included"), AppColors.primary),
            _buildOverviewItem(
                Icons.check_circle, tr("flexible_booking"), AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: iconColor),
          SizedBox(width: 12.w),
          Expanded(
              child: Text(text,
                  style:
                      TextStyle(fontSize: 15.sp, color: Colors.grey.shade800))),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                        child: Text(tr("agree_to_terms"),
                            style: TextStyle(
                                fontSize: 15.sp, color: Colors.grey.shade800))),
                  ],
                ),
                Divider(height: 1.h, color: Colors.grey.shade200),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                  child: _buildTotalPrice(),
                )
              ],
            )));
  }

  Widget _buildTotalPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tr("total_price"),
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        Text(
          '\$${widget.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _agreedToTerms
            ? () async {
                // Check if widget is still mounted before proceeding
                if (!mounted) return;

                try {
                  var stops = context.read<CarCubit>().state.stops;
                  stops = List.from(stops); // Make mutable copy

                  // Ensure there's at least a pickup and return station, even if no intermediate stops are added
                  if (stops.isEmpty) {
                    final pickup = context.read<CarCubit>().state.pickupStation;
                    final dropoff = context.read<CarCubit>().state.returnStation;
                    if (pickup != null) stops.add(pickup);
                    if (dropoff != null) stops.add(dropoff);
                  }

                  if (stops.length < 2) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select at least a pickup and return station.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  // Send notification to owner after agreeing to terms
                  final authCubit = context.read<AuthCubit>();
                  final currentUser = authCubit.userModel;
                  
                  if (currentUser == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User not found. Please login again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  final renterName = '${currentUser.firstName} ${currentUser.lastName}';
                  final renterId = currentUser.id;

                  // For demo purposes, use a valid owner ID or create one
                  final ownerId = widget.car.ownerId == 'owner1' ? '1' : widget.car.ownerId;

                  // Create booking request data
                  final bookingRequestData = {
                    'renterId': renterId,
                    'renterName': renterName,
                    'carId': widget.car.id,
                    'carBrand': widget.car.brand,
                    'carModel': widget.car.model,
                    'totalPrice': widget.totalPrice,
                    'pickupStation': context.read<CarCubit>().state.pickupStation?.name ?? '',
                    'returnStation': context.read<CarCubit>().state.returnStation?.name ?? '',
                    'dateRange': context.read<CarCubit>().state.dateRange?.toString() ?? '',
                    'status': 'pending',
                    'createdAt': DateTime.now().toIso8601String(),
                    'ownerId': ownerId, // Add owner ID to booking data
                  };

                  // Send FCM notification to car owner (only if owner exists)
                  try {
                    await NotificationService().sendCarBookedNotification(
                      ownerId: ownerId,
                      renterName: renterName,
                      carBrand: widget.car.brand,
                      carModel: widget.car.model,
                    );
                  } catch (e) {
                    print('FCM notification failed (owner may not exist): $e');
                    // Don't fail the booking request if notification fails
                  }

                  // Also send to Firestore for in-app notifications with booking data
                  try {
                    await NotificationService().sendNotificationToUser(
                      userId: ownerId,
                      title: 'New Booking Request',
                      body: 'You have a new booking request for your car ${widget.car.brand} ${widget.car.model} from $renterName.',
                      type: 'owner',
                      notificationType: 'car_booked',
                      bookingData: bookingRequestData,
                    );
                  } catch (e) {
                    print('Error sending notification to Firestore: $e');
                    // Don't fail the booking request if notification fails
                  }

                  // Save booking request to Firestore for tracking
                  await _saveBookingRequest(bookingRequestData);

                  // Branch by car rental option
                  if (widget.car.rentalOptions.availableWithDriver) {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DepositInputScreen(
                            car: widget.car,
                            totalPrice: widget.totalPrice,
                            stops: stops,
                          ),
                        ),
                      );
                    }
                  } else if (widget.car.rentalOptions.availableWithoutDriver) {
                    // For without driver, show a confirmation dialog and wait for owner acceptance
                    if (mounted) {
                      _showBookingRequestDialog(context, renterName);
                    }
                  }
                } catch (e) {
                  print('Error in booking request: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating booking request: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(tr("continue_button"),
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }

  void _showBookingRequestDialog(BuildContext context, String renterName) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
            SizedBox(width: 8.w),
            Text('Booking Request Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your booking request for ${widget.car.brand} ${widget.car.model} has been sent to the car owner.',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'You will receive a notification once the owner accepts or declines your request.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.pop(context);
                // Navigate back to home screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  ScreensName.homeScreen,
                  (route) => false,
                );
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBookingRequest(Map<String, dynamic> bookingRequestData) async {
    try {
      // Import FirebaseFirestore at the top of the file
      await FirebaseFirestore.instance.collection('booking_requests').add({
        ...bookingRequestData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Booking request saved successfully');
    } catch (e) {
      print('Error saving booking request: $e');
      // Don't throw the error to avoid crashing the app
    }
  }
}
