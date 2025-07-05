import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'package:test_cark/features/home/presentation/screens/booking_screens/payment_methods_screen.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../model/car_model.dart';
import '../../../model/car_rental_preview_model.dart';
import '../../cubit/car_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/booking_api_cubit.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';

import 'deposit_input_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final CarModel car;
  final CarRentalPreviewModel? rentalPreview;

  const BookingSummaryScreen({
    super.key,
      required this.car,
    this.rentalPreview,
  });

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
    return BlocListener<BookingApiCubit, BookingApiState>(
        listener: (context, state) {
          if (state is BookingApiSuccess) {
            // Send notification to car owner
            _sendNotificationToOwner(context, state.data);

            // Show success message and navigate based on rental type
            final rentalType = state.data['rental_type'];
            if (rentalType == 'WithDriver') {
              // Navigate to payment screen for with driver
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentMethodsScreen(
                    car: widget.car,
                    totalPrice: widget.rentalPreview?.totalPrice ?? 0.0,
                  ),
                ),
              );
            } else {
              // Show confirmation dialog for without driver
              _showBookingRequestDialog(
                  context, 'Your booking request has been sent');
            }
          } else if (state is BookingApiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
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
        ));
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
    // Use car details from rental preview if available, otherwise fallback to car model
    final carDetails = widget.rentalPreview?.carDetails;
    final displayBrand = carDetails?.brand ?? widget.car.brand;
    final displayModel = carDetails?.model ?? widget.car.model;
    final displayCarType = widget.car.carType;
    final displayColor = carDetails?.color;
    final displayTransmission = carDetails?.transmissionType;
    final displayFuelType = carDetails?.fuelType;
    final displaySeatingCapacity = carDetails?.seatingCapacity ?? widget.car.seatingCapacity;

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
                    '$displayBrand $displayModel',
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
                          displayCarType,
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
                  // Add additional car details from API if available
                  if (carDetails != null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _buildCarDetailChip(Icons.palette, displayColor ?? 'N/A'),
                        SizedBox(width: 8.w),
                        _buildCarDetailChip(Icons.settings, displayTransmission ?? 'N/A'),
                        SizedBox(width: 8.w),
                        _buildCarDetailChip(Icons.local_gas_station, displayFuelType ?? 'N/A'),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildCarDetailChip(Icons.person, '$displaySeatingCapacity seats'),
                        SizedBox(width: 8.w),
                        _buildCarDetailChip(Icons.star, '${carDetails.avgRating.toStringAsFixed(1)} (${carDetails.totalReviews})'),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey.shade600, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Owner: ${carDetails.ownerName}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            // Show rental details from API if available
            if (widget.rentalPreview != null) ...[
              _buildRentalDetailsSection(),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey[200]),
              SizedBox(height: 16.h),
            ],
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
            if (widget.rentalPreview != null) ...[
              _buildOverviewItem(
                Icons.speed,
                '${widget.rentalPreview!.dailyKmLimit.toInt()} km daily limit',
                Colors.orange,
              ),
              _buildOverviewItem(
                Icons.attach_money,
                '\$${widget.rentalPreview!.extraKmCost.toStringAsFixed(2)} per extra km',
                Colors.red,
              ),
            ] else ...[
            _buildOverviewItem(
              Icons.speed,
              tr("km_included"),
              Colors.orange,
            ),
            ],
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

  Widget _buildRentalDetailsSection() {
    if (widget.rentalPreview == null) return SizedBox.shrink();
    
    final rental = widget.rentalPreview!;
    
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'Rental Period',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildRentalDetailItem(
                  'From',
                  rental.startDate,
                  Icons.flight_takeoff,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildRentalDetailItem(
                  'To',
                  rental.endDate,
                  Icons.flight_land,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildRentalDetailItem(
                  'Duration',
                  '${rental.durationDays} days',
                  Icons.schedule,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildRentalDetailItem(
                  'Daily Price',
                  '\$${rental.dailyPrice.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 14.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'Pickup: ${rental.pickupAddress}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 14.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'Dropoff: ${rental.dropoffAddress}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12.sp, color: Colors.grey[600]),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
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
                      color:
                          _agreedToTerms ? AppColors.primary : Colors.grey[300],
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
          // Show pricing details from API if available
          if (widget.rentalPreview != null) ...[
            _buildPricingDetailsSection(),
          ],
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
                      '\$${(widget.rentalPreview?.totalPrice ?? 0.0).toStringAsFixed(2)}',
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

  Widget _buildPricingDetailsSection() {
    if (widget.rentalPreview == null) return SizedBox.shrink();
    
    final pricing = widget.rentalPreview!.pricing;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 16.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          _buildPricingRow('Daily Price', '\$${pricing.dailyPrice.toStringAsFixed(2)}'),
          _buildPricingRow('Base Cost', '\$${pricing.baseCost.toStringAsFixed(2)}'),
          _buildPricingRow('Service Fee (${pricing.serviceFeePercentage}%)', '\$${pricing.serviceFee.toStringAsFixed(2)}'),
          Divider(color: Colors.grey[200], height: 24.h),
          _buildPricingRow('Deposit (${pricing.depositPercentage}%)', '\$${pricing.depositAmount.toStringAsFixed(2)}', isHighlighted: true),
          _buildPricingRow('Remaining Amount', '\$${pricing.remainingAmount.toStringAsFixed(2)}', isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: isHighlighted ? Colors.black87 : Colors.grey[600],
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isHighlighted ? AppColors.primary : Colors.black87,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
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
                    final dropoff =
                        context.read<CarCubit>().state.returnStation;
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

                  // User data loss
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

                  // Get car cubit state
                  final carCubit = context.read<CarCubit>();
                  final pickupLocation = carCubit.state.pickupStation;
                  final dropoffLocation = carCubit.state.returnStation;
                  final dateRange = carCubit.state.dateRange;
                  final paymentMethod = 'visa'; // Default payment method

                  if (pickupLocation == null ||
                      dropoffLocation == null ||
                      dateRange == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Determine rental type based on options
                  String rentalType = 'WithoutDriver';
                  // For now, default to WithoutDriver since we don't have this info in preview
                  // This can be updated when the API provides rental type information

                  // Create rental using Django API
                  context.read<BookingApiCubit>().createRental(
                        car: widget.car,
                        startDate: dateRange.start,
                        endDate: dateRange.end,
                        rentalType: rentalType,
                        pickupLocation: pickupLocation,
                        dropoffLocation: dropoffLocation,
                        paymentMethod: paymentMethod,
                        stops: carCubit.state.stops,
                        selectedCardId: 1
                      );

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
              "Rent Car",
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

  void _sendNotificationToOwner(BuildContext context, Map<String, dynamic> bookingData) {
    try {
      // Get current user info
      final currentUser = context.read<AuthCubit>().currentUser;
      if (currentUser == null) return;

      // Get car owner info from the car model
      final carOwnerId = widget.car.ownerId;
      final carOwnerName = 'Car Owner'; // We don't have owner name in car model

      // Send notification to car owner using in-app notification system
      context.read<NotificationCubit>().sendBookingNotification(
        renterName: currentUser.firstName ?? currentUser.email ?? 'User',
        carBrand: widget.car.brand,
        carModel: widget.car.model,
        ownerId: carOwnerId,
        renterId: currentUser.id?.toString() ?? '',
        type: 'booking_request',
        totalPrice: widget.rentalPreview?.totalPrice ?? 0.0,
        rentalId: bookingData['id']?.toString(),
      );

      print('✅ Notification sent to car owner: $carOwnerName');
    } catch (e) {
      print('❌ Error sending notification to owner: $e');
    }
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
}
