import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/car_model.dart';

class CarCardWidget extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CarCardWidget({
    super.key,
    required this.car,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final price = car.rentalOptions.availableWithDriver
        ? car.rentalOptions.dailyRentalPriceWithDriver
        : car.rentalOptions.dailyRentalPrice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 250.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(car.imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top section with car info chips
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${car.brand} ${car.model}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'or similar | ${car.carType}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),

                      // Bottom section with pricing and details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.person_outline,
                                text: '${car.seatingCapacity}',
                              ),
                              SizedBox(width: 8.w),
                              _buildInfoChip(
                                icon: Icons.luggage_outlined,
                                text: '${car.luggageCapacity}',
                              ),
                              SizedBox(width: 8.w),
                              _buildInfoChip(
                                icon: Icons.settings_input_component_outlined,
                                text: car.transmissionType,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '\$${price?.toStringAsFixed(2) ?? 'N/A'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' / day',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (price != null)
                                Text(
                                  '\$${(price * 3).toStringAsFixed(2)} total',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Edit and Delete icons (top right)
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 22.sp),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent, size: 22.sp),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade300,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// while select without driver it does not filter correctly