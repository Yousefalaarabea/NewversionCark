import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import 'package:test_cark/features/home/presentation/widgets/rental_widgets/station_input.dart';
import 'package:test_cark/features/home/presentation/widgets/rental_widgets/stops_station_input.dart';
import '../../cubit/car_cubit.dart';
import 'date_selector.dart';
import 'driver_filter_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// This widget is used to display the rental search form at the bottom of the screen
class RentalSearchForm extends StatelessWidget {
  const RentalSearchForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(20.r),

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DriverFilterSelector(),
            SizedBox(height: 20.h),

            // Pick-up
            const StationInput(isPickup: true),
            SizedBox(height: 20.h),

            // Return Station (Optional)
            const StationInput(isPickup: false),
            SizedBox(height: 20.h),

            // Stops Section (only with driver)
            BlocBuilder<CarCubit, dynamic>(
              builder: (context, state) {
                final withDriver = state.withDriver;
                if (withDriver == true) {
                  return Column(
                    children: [
                      const StopsStationInput(),
                      SizedBox(height: 20.h),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Date Selector
            const DateSelector(),
            SizedBox(height: 40.h),

            // Show Offers Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, ScreensName.homeScreen);
                },

                // Show Offers Button
                child: Text(
                  TextManager.showOffers.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
