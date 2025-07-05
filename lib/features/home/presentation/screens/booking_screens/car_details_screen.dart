import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'dart:io';

import '../../../../../config/routes/screens_name.dart';
import '../../cubit/car_cubit.dart';
import '../../cubit/choose_car_state.dart';
import '../../model/car_model.dart';
import '../../../model/car_rental_preview_model.dart';
import '../../../../../core/car_rental_service.dart';
import 'package:test_cark/features/cars/presentation/cubits/add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';

class CarDetailsScreen extends StatefulWidget {
  final CarBundle carBundle;

  const CarDetailsScreen({super.key, required this.carBundle});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  CarRentalPreviewModel? _rentalPreview;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRentalPreview();
  }

  Future<void> _fetchRentalPreview() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final carCubit = context.read<CarCubit>();
      final state = carCubit.state;
      
      if (state.dateRange == null || state.pickupStation == null || state.returnStation == null) {
        throw Exception('Missing required booking information');
      }

      final startDate = state.dateRange!.start.toIso8601String().split('T')[0];
      final endDate = state.dateRange!.end.toIso8601String().split('T')[0];

      final rentalPreview = await CarRentalService().getRentalPreview(
        carId: widget.carBundle.car.id,
        startDate: startDate,
        endDate: endDate,
        pickupLatitude: state.pickupStation!.lat?.toString() ?? '',
        pickupLongitude: state.pickupStation!.lng?.toString() ?? '',
        pickupAddress: state.pickupStation!.address,
        dropoffLatitude: state.returnStation!.lat?.toString() ?? '',
        dropoffLongitude: state.returnStation!.lng?.toString() ?? '',
        dropoffAddress: state.returnStation!.address,
        paymentMethod: "visa", // Default payment method
        selectedCard: 1, // Default selected card
      );

      setState(() {
        _rentalPreview = rentalPreview;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.carBundle.car;
    return BlocBuilder<CarCubit, ChooseCarState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, car),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildCarHeader(car),
                      SizedBox(height: 16.h),
                      // Features Section
                      _buildFeaturesSection(car),
                      SizedBox(height: 24.h),
                      // Rental Summary Section
                      _buildRentalSummarySection(),
                      SizedBox(height: 32.h),
                      // Action Section
                      _buildBookingButton(context, car),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, CarModel car) {
    ImageProvider imageProvider;
    
    // Try to get image from rental preview first (new API)
    if (_rentalPreview != null && _rentalPreview!.carDetails.firstImageUrlEncoded != null) {
      imageProvider = NetworkImage(_rentalPreview!.carDetails.firstImageUrlEncoded!);
    } else if (car.imageUrl != null && car.imageUrl!.isNotEmpty) {
      // Fallback to car model image
      if (car.imageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(car.imageUrl!);
      } else {
        imageProvider = FileImage(File(car.imageUrl!));
      }
    } else {
      // Default placeholder image
      imageProvider = const AssetImage('assets/images/placeholder_car.png');
    }
    
    return SliverAppBar(
      expandedHeight: 250.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      stretch: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.darken,
          child: Image(
            image: imageProvider,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to placeholder if image fails to load
              return Image.asset(
                'assets/images/placeholder_car.png',
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildCarHeader(CarModel car) {
    // Use car details from API if available, otherwise fallback to car model
    final carDetails = _rentalPreview?.carDetails;
    final displayBrand = carDetails?.brand ?? car.brand;
    final displayModel = carDetails?.model ?? car.model;
    final displayCarType = car.carType; // Keep from original car model for now
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$displayBrand $displayModel',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${tr("or_similar")} | $displayCarType',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    displayCarType,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            // Add additional car details from API if available
            if (carDetails != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '${carDetails.avgRating.toStringAsFixed(1)} (${carDetails.totalReviews} ${tr("reviews")})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.person, color: Colors.grey.shade600, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    carDetails.ownerName,
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
    );
  }

  Widget _buildFeaturesSection(CarModel car) {
    // Use car details from API if available, otherwise fallback to car model
    final carDetails = _rentalPreview?.carDetails;
    final seatingCapacity = carDetails?.seatingCapacity ?? car.seatingCapacity;
    final transmissionType = carDetails?.transmissionType ?? car.transmissionType;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFeatureChip(Icons.person_outline, '$seatingCapacity'),
            _buildFeatureChip(Icons.luggage_outlined, '-'),
            _buildFeatureChip(Icons.settings_input_component_outlined, transmissionType.tr()),
            if (carDetails != null) ...[
              _buildFeatureChip(Icons.local_gas_station, carDetails.fuelType.tr()),
              _buildFeatureChip(Icons.palette, carDetails.color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRentalSummarySection() {
    if (_isLoading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  tr("loading_rental_details"),
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
              SizedBox(height: 16.h),
              Text(
                tr("error_loading_details"),
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _fetchRentalPreview,
                child: Text(tr("retry")),
              ),
            ],
          ),
        ),
      );
    }

    if (_rentalPreview == null) {
      return SizedBox.shrink();
    }

    final pricing = _rentalPreview!.pricing;
    final usagePolicy = _rentalPreview!.usagePolicy;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("rental_summary"),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSummaryRow(tr("daily_price"), '\$${pricing.dailyPrice.toStringAsFixed(2)}'),
            _buildSummaryRow(tr("base_cost"), '\$${pricing.baseCost.toStringAsFixed(2)}'),
            _buildSummaryRow(tr("service_fee"), '\$${pricing.serviceFee.toStringAsFixed(2)} (${pricing.serviceFeePercentage}%)'),
            _buildSummaryRow(tr("daily_km_limit"), '${usagePolicy.dailyKmLimit.toInt()} ${tr("km")}'),
            _buildSummaryRow(tr("extra_km_cost"), '\$${usagePolicy.extraKmCost.toStringAsFixed(2)} / km'),
            _buildSummaryRow(tr("deposit_amount"), '\$${pricing.depositAmount.toStringAsFixed(2)} (${pricing.depositPercentage}%)'),
            Divider(color: Colors.grey.shade200, height: 32.h),
            _buildSummaryRow(tr("total_cost"), '\$${pricing.totalCost.toStringAsFixed(2)}', isTotal: true),
            _buildSummaryRow(tr("remaining_amount"), '\$${pricing.remainingAmount.toStringAsFixed(2)}', isRemaining: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isRemaining = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey.shade600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 20.sp : 15.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? AppColors.primary : (isRemaining ? Colors.green : Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 30.sp),
        SizedBox(height: 8.h),
        SizedBox(
          width: 60.w,
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700, overflow: TextOverflow.ellipsis),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingButton(BuildContext context, CarModel car) {
    if (_isLoading || _rentalPreview == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: null,
          child: Text(
            tr("loading"),
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            ScreensName.bookingSummaryScreen,
            arguments: {
              'car': car,
              'rentalPreview': _rentalPreview,
              'carBundle': widget.carBundle,
            },
          );
        },
        child: Text(
          tr("continue_button"),
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}
