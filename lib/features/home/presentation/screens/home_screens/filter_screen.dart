import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import '../../cubit/car_cubit.dart';
import '../../widgets/filter_widgets/car_filters.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carCubit = context.read<CarCubit>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.04.sw, vertical: 0.02.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Close & Clear
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  IconButton(
                    icon: Icon(Icons.close ,color: Theme.of(context).colorScheme.onSecondary,),
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, ScreensName.mainNavigationScreen, (route) => false),
                  ),

                  // Filter Title
                  Text(
                    TextManager.filter.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      carCubit.resetFilters();
                    },
                    child: Text(
                      TextManager.clear.tr(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 0.02.sh),

              // Car Filters Section
              const CarFilters(),

              SizedBox(height: 0.08.sh),

              // Show offers
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    // final carCubit = context.read<CarCubit>();

                    // Set the filters in the CarCubit
                    carCubit.setFilters(
                      carType: carCubit.state.carType,
                      category: carCubit.state.category,
                      transmission: carCubit.state.transmission,
                      fuel: carCubit.state.fuel,
                      withDriver: carCubit.state.withDriver,
                      withoutDriver: carCubit.state.withoutDriver,
                    );

                    Navigator.pushNamedAndRemoveUntil(
                        context, ScreensName.mainNavigationScreen, (route) => false);
                  },

                  // Apply Filters Button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Button Text
                  child: Text(
                    TextManager.applyButton.tr(),
                    style: Theme.of(context).elevatedButtonTheme.style!.textStyle!.resolve({}),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
