import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/car_model.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'dart:io';

class CarCardWidget extends StatelessWidget {
  final CarModel car;
  final CarRentalOptions? rentalOptions;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarCardWidget({
    super.key,
    required this.car,
    required this.rentalOptions,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate price - show default price if rental options are not available
    double? price;
    if (rentalOptions != null) {
      price = rentalOptions!.availableWithDriver
          ? rentalOptions!.dailyRentalPriceWithDriver
          : rentalOptions!.dailyRentalPrice;
    } else {
      // Default price when rental options are not available
      price = 150.0; // Default daily price
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: _getCarImageProvider(),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top section with car info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car brand and model
                        Text(
                          '${car.brand}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          car.model,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        
                        // Car type and category
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                car.carType,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                car.carCategory,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bottom section with details and price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car specifications
                        Row(
                          children: [
                            _buildSpecChip(
                              icon: Icons.person_outline,
                              text: '${car.seatingCapacity} seats',
                            ),
                            SizedBox(width: 12.w),
                            _buildSpecChip(
                              icon: Icons.settings_input_component_outlined,
                              text: car.transmissionType,
                            ),
                            SizedBox(width: 12.w),
                            _buildSpecChip(
                              icon: Icons.local_gas_station_outlined,
                              text: car.fuelType,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        
                        // Price and year
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '\$${(price ?? 0).toStringAsFixed(0)}/day',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (rentalOptions == null)
                                  Text(
                                    'Price estimate',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.white.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${car.year}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Edit and Delete icons (top right) - only for owners
              if (onEdit != null || onDelete != null)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Row(
                    children: [
                      if (onEdit != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.white, size: 20.sp),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                          ),
                        ),
                      if (onDelete != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white, size: 20.sp),
                            onPressed: onDelete,
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: 14.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getCarImageProvider() {
    if (car.imageUrl != null && car.imageUrl!.isNotEmpty) {
      if (car.imageUrl!.startsWith('http')) {
        return NetworkImage(car.imageUrl!);
      } else {
        return FileImage(File(car.imageUrl!));
      }
    } else {
      // Use a default car image based on brand
      return AssetImage('assets/images/home/car_background.jpeg');
    }
  }
}

// while select without driver it does not filter correctly