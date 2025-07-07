import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/utils/assets_manager.dart';
import '../../cubit/car_cubit.dart';
import '../../model/car_model.dart';
import '../../model/location_model.dart';
import '../../widgets/rental_widgets/date_selector.dart';
import '../../widgets/rental_widgets/driver_filter_selector.dart';
import '../../widgets/rental_widgets/payment_method_selector.dart';
import '../../widgets/rental_widgets/station_input.dart';
import '../../widgets/rental_widgets/stops_station_input.dart';
import 'package:test_cark/features/home/presentation/widgets/rental_widgets/rental_search_form.dart';
import 'package:test_cark/features/home/presentation/widgets/rental_widgets/rental_summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalSearchScreen extends StatelessWidget {
  const RentalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 320.h,
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/img/img.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ],
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.r),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: BlocBuilder<CarCubit, dynamic>(
                builder: (context, state) {
                  final withDriver = state.withDriver;
                  final withoutDriver = state.withoutDriver;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header text
                      Padding(
                        padding: EdgeInsets.only(bottom: 25.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.car_rental,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rental Details',
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Choose your preferences',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const DriverFilterSelector(),
                      //
                      SizedBox(height: 20.h),

                      const StationInput(isPickup: true),

                      SizedBox(height: 20.h),

                      // Return Station (Optional)
                      const StationInput(isPickup: false),

                      SizedBox(height: 16.h),

                      // Stops Section (only with driver)
                      if (withDriver == true) ...[
                        const StopsStationInput(),
                        SizedBox(height: 16.h),
                      ],

                      // Date Selector
                      const DateSelector(),
                      SizedBox(height: 16.h),

                      SizedBox(height: 40.h),

                      // Show offers button
                      Container(
                        width: double.infinity,
                        height: 55.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          onPressed: () async {
                            // Enable validation first
                            context.read<CarCubit>().enableValidation();

                            // Validate required fields
                            final pickupStation = state.pickupStation;
                            final returnStation = state.returnStation;
                            final dateRange = state.dateRange;
                            final withDriver = state.withDriver;
                            final withoutDriver = state.withoutDriver;
                            // final selectedPaymentMethod = state.selectedPaymentMethod;

                            // Check if pickup station is filled
                            if (pickupStation == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'Please select a pick-up station',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Check if return station is filled
                            if (returnStation == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'Please select a return station',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Check if date range is selected
                            if (dateRange == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'Please select a date range',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                              return;
                            }

                            // تحقق من اختيار السائق
                            // if (withDriver == null && withoutDriver ==  null) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Row(
                            //         children: [
                            //           Icon(
                            //             Icons.warning,
                            //             color: Colors.white,
                            //             size: 20.sp,
                            //           ),
                            //           SizedBox(width: 10.w),
                            //           Expanded(
                            //             child: Text(
                            //               'Please select a driver option',
                            //               style: TextStyle(
                            //                 fontSize: 14.sp,
                            //                 fontWeight: FontWeight.w500,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       backgroundColor: Colors.orange,
                            //       duration: Duration(seconds: 3),
                            //       behavior: SnackBarBehavior.floating,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10.r),
                            //       ),
                            //     ),
                            //   );
                            //   return;
                            // }
                            //
                            // // Different flow based on driver selection
                            // if (withDriver == true || withDriver == false) {
                            //   // Check if payment method is selected
                            //   // if (selectedPaymentMethod == null) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //         content: Row(
                            //           children: [
                            //             Icon(
                            //               Icons.warning,
                            //               color: Colors.white,
                            //               size: 20.sp,
                            //             ),
                            //             SizedBox(width: 10.w),
                            //             Expanded(
                            //               child: Text(
                            //                 'Please select a payment method',
                            //                 style: TextStyle(
                            //                   fontSize: 14.sp,
                            //                   fontWeight: FontWeight.w500,
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //         backgroundColor: Colors.orange,
                            //         duration: Duration(seconds: 3),
                            //         behavior: SnackBarBehavior.floating,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(10.r),
                            //         ),
                            //       ),
                            //     );
                            //     return;
                            //   }
                            //
                            //   // Navigate to offers/home screen
                            //   Navigator.pushNamedAndRemoveUntil(
                            //     context,
                            //     ScreensName.homeScreen,
                            //     (route) => false
                            //   );
                            // //
                            // // }
                            // // else {
                            //   // No driver selection - show message
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Row(
                            //         children: [
                            //           Icon(
                            //             Icons.warning,
                            //             color: Colors.white,
                            //             size: 20.sp,
                            //           ),
                            //           SizedBox(width: 10.w),
                            //           Expanded(
                            //             child: Text(
                            //               'Please select a driver option',
                            //               style: TextStyle(
                            //                 fontSize: 14.sp,
                            //                 fontWeight: FontWeight.w500,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       backgroundColor: Colors.orange,
                            //       duration: Duration(seconds: 3),
                            //       behavior: SnackBarBehavior.floating,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10.r),
                            //       ),
                            //     ),
                            //   );
                            // // }
                            if (withDriver == null && withoutDriver == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'Please select a driver option',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                              return;
                            }

                            // هذا الشرط (withDriver == true || withDriver == false) يعني أنه تم اختيار أحد الخيارين
                            if (withDriver == true || withoutDriver == true) {
                              // إذا كل الشروط السابقة تحققت، انتقل إلى الشاشة الرئيسية
                              Navigator.pushNamedAndRemoveUntil(context,
                                  ScreensName.homeScreen, (route) => false);
                            } else {
                              // هذا الـ else يتعامل مع حالة عدم اختيار أي من خيارات السائق
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'Please select a driver option',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Show offers',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RentalBookingHistoryScreen extends StatelessWidget {
  const RentalBookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: Center(
        child: Text(
          'Your booking history will appear here.',
          style: TextStyle(fontSize: 18.sp, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
