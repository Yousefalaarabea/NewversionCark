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
import 'package:test_cark/features/cars/presentation/cubits/add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';

class CarDetailsScreen extends StatelessWidget {
  final CarBundle carBundle;

  const CarDetailsScreen({super.key, required this.carBundle});

  @override
  Widget build(BuildContext context) {
    final car = carBundle.car;
    final rentalOptions = carBundle.rentalOptions;
    final usagePolicy = carBundle.usagePolicy;
    return BlocBuilder<CarCubit, ChooseCarState>(
      builder: (context, state) {
        final rentalDays =
            state.dateRange != null ? state.dateRange!.duration.inDays : 1;

        final totalKilometers = rentalDays * (usagePolicy?.dailyKmLimit?.toInt() ?? 0);

        final price = (state.withDriver ?? false)
            ? rentalOptions?.dailyRentalPriceWithDriver
            : rentalOptions?.dailyRentalPrice;

        final totalPrice = (price ?? 0) * rentalDays;

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
                      _buildCarHeader(car),
                      SizedBox(height: 24.h),
                      _buildCarFeatures(car),
                      SizedBox(height: 24.h),
                      _buildRentalSummary(rentalDays, totalKilometers, totalPrice, usagePolicy),
                      SizedBox(height: 32.h),
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
    if (car.imageUrl != null && car.imageUrl!.isNotEmpty) {
      if (car.imageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(car.imageUrl!);
      } else {
        imageProvider = FileImage(File(car.imageUrl!));
      }
    } else {
      imageProvider = AssetImage('assets/images/placeholder_car.png');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${car.brand} ${car.model}',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${tr("or_similar")} | ${car.carType}',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCarFeatures(CarModel car) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeatureChip(
            Icons.person_outline, '${car.seatingCapacity} ${tr("seats")}'),
        _buildFeatureChip(
            Icons.luggage_outlined, '- ${tr("bags")}'),
        _buildFeatureChip(Icons.settings_input_component_outlined,
            car.transmissionType.tr()),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 30.sp),
        SizedBox(height: 8.h),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildRentalSummary(
      int rentalDays, int totalKilometers, double totalPrice, CarUsagePolicy? usagePolicy) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("rental_summary"),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          _buildSummaryRow(
              tr("rental_duration"),
              '$rentalDays ${rentalDays > 1 ? tr("days") : tr("day")}'),
          _buildSummaryRow(
              tr("mileage_package"), '$totalKilometers ${tr("km_included_dynamic")}'),
          _buildSummaryRow(tr("extra_kilometer_cost"),
              '\${usagePolicy?.extraKmCost?.toStringAsFixed(2) ?? "-"} / km'),
          Divider(color: Colors.grey.shade200, height: 32.h),
          _buildSummaryRow(
            tr("total_price"),
            '\${totalPrice.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20.sp : 15.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context, CarModel car) {
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
          final rentalDays =
              context.read<CarCubit>().state.dateRange?.duration.inDays ?? 1;
          final price = 0.0; // Default value, update as needed
          final totalPrice = price * rentalDays;

          Navigator.pushNamed(
            context,
            ScreensName.bookingSummaryScreen,
            arguments: {
              'car': car,
              'totalPrice': totalPrice,
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
