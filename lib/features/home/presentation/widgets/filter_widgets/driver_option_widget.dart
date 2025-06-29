import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import 'package:test_cark/features/home/presentation/widgets/home_widgets/reusable_container.dart';
import '../../cubit/car_cubit.dart';

// Done
class DriverOptionWidget extends StatelessWidget {
  const DriverOptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const options = CarCubit.driverOptions;
    final state = context.watch<CarCubit>().state;
    final cubit = context.read<CarCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver Options Title
        Text(
          TextManager.driverOption.tr(),
          style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 0.01.sh),

        // Driver Options List
        SizedBox(
          height: 0.05.sh,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => SizedBox(width: 0.03.sw),
            itemBuilder: (context, index) {
              // Get the option and check if it is selected
              final option = options[index];
              final isSelected = (option.label == TextManager.withDriver.tr() &&
                  state.withDriver == true) ||
                  (option.label == TextManager.withoutDriver.tr() &&
                      state.withoutDriver == true);

              return GestureDetector(
                onTap: () {
                  if (option.label == TextManager.withDriver.tr()) {
                    // If already selected, deselect it
                    if (state.withDriver == true) {
                      cubit.setFilters(
                        withDriver: null,
                        withoutDriver: null,
                      );
                    } else {
                      cubit.setFilters(
                        withDriver: true,
                        withoutDriver: false,
                      );
                    }
                  } else if (option.label == TextManager.withoutDriver.tr()) {
                    // If already selected, deselect it
                    if (state.withoutDriver == true) {
                      cubit.setFilters(
                        withDriver: null,
                        withoutDriver: null,
                      );
                    } else {
                      cubit.setFilters(
                        withDriver: false,
                        withoutDriver: true,
                      );
                    }
                  }
                },

                // Driver Options Container
                child: ReusableContainer(
                  isSelected: isSelected,
                  option: Row(
                    children: [
                      SizedBox(width: 0.01.sw),

                      // Icon for the driver option
                      Icon(
                        option.icon,
                        size: 20.sp,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSecondary,
                      ),

                      SizedBox(width: 0.01.sw),

                      // Text for the driver option
                      Text(
                        option.label,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
