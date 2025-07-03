import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'package:test_cark/features/home/presentation/screens/booking_screens/payment_methods_screen.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../model/car_model.dart';
import '../../cubit/car_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'deposit_input_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final CarModel car;
  final double totalPrice;

  const BookingSummaryScreen(
      {super.key, required this.car, required this.totalPrice});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen>
    with TickerProviderStateMixin {
  bool _agreedToTerms = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          tr("booking_confirmation"),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 24.h),
                _buildCarDetailsCard(),
                SizedBox(height: 20.h),
                _buildConditionsCard(),
                SizedBox(height: 20.h),
                _buildBookingOverviewCard(),
                SizedBox(height: 24.h),
                _buildAgreementSection(),
                SizedBox(height: 32.h),
                _buildContinueButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Review your booking details before proceeding',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Car Details',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.car.brand} ${widget.car.model}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.r,
                          vertical: 4.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          widget.car.carType,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '• ${tr("or_similar")}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.security,
                    color: Colors.orange,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  tr("conditions"),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.05),
                    Colors.orange.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr("maximum_deductible"),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.r,
                          vertical: 6.r,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          tr("up_to_800"),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        tr("included_no_extra_cost"),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingOverviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.list_alt,
                    color: Colors.green,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  tr("booking_overview"),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildOverviewItem(
              Icons.verified,
              tr("third_party_insurance"),
              Colors.green,
            ),
            _buildOverviewItem(
              Icons.shield,
              tr("collision_damage_waiver"),
              Colors.blue,
            ),
            _buildOverviewItem(
              Icons.security,
              tr("theft_protection"),
              Colors.purple,
            ),
            _buildOverviewItem(
              Icons.speed,
              tr("km_included"),
              Colors.orange,
            ),
            _buildOverviewItem(
              Icons.schedule,
              tr("flexible_booking"),
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String text, Color iconColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: iconColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              icon,
              size: 16.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: _agreedToTerms ? AppColors.primary : Colors.grey[300],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: _agreedToTerms
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16.sp,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    tr("agree_to_terms"),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr("total_price"),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '\$${widget.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.r,
                    vertical: 8.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                      // Navigate to login screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
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

                  // Save booking request to Firestore for tracking
                  await _saveBookingRequest(bookingRequestData);

                  // Branch by car rental option
                  if (widget.car.rentalOptions.availableWithDriver) {
                    // ✅ With Driver Flow: Navigate directly to deposit input screen
                    // This is for cars that come with a driver, so no owner approval needed

                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentMethodsScreen(
                            car: widget.car,
                            totalPrice: widget.totalPrice,
                          ),
                        ),
                      );
                    }
                  } else if (widget.car.rentalOptions.availableWithoutDriver) {
                    // ✅ Without Driver Flow: Show confirmation dialog and wait for owner acceptance
                    // This is for cars without driver, so owner needs to approve the request
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
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_forward,
              color: _agreedToTerms ? Colors.white : Colors.grey[500],
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              tr("continue_button"),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _agreedToTerms ? Colors.white : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingRequestDialog(BuildContext context, String renterName) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Booking Request Sent',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'You will receive a notification once the owner accepts or declines your request.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
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
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
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