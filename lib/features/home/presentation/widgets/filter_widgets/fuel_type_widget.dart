import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/widgets/home_widgets/reusable_container.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../cubit/car_cubit.dart';
// Done
class FuelTypeWidget extends StatelessWidget {
  const FuelTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const fuelTypes = CarCubit.fuelTypes;
    final selected = context.watch<CarCubit>().state.fuel;
    final cubit = context.read<CarCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextManager.fuelType.tr(),
          style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 0.01.sh),

        // Fuel Type List
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fuelTypes.length,
            separatorBuilder: (_, __) => SizedBox(width: 0.03.sw),
            itemBuilder: (context, index) {
              final fuel = fuelTypes[index];
              final isSelected = selected == fuel.label;

              return GestureDetector(
                onTap: () => cubit.setFuel(fuel.label),

                // Fuel Type Container
                child: ReusableContainer(isSelected: isSelected, option: Row(
                  children: [
                    SizedBox(width: 0.01.sw),

                    Icon(
                      fuel.icon,
                      size: 20.sp,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),

                    SizedBox(width: 0.01.sw),

                    Text(
                      fuel.label,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),)
              );
            },
          ),
        ),
      ],
    );
  }
}
