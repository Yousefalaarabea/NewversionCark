import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/widgets/home_widgets/reusable_container.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../cubit/car_cubit.dart';

// Done
class CarTypeWidget extends StatelessWidget {
  const CarTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const carTypes = CarCubit.carTypes;
    final selected = context.watch<CarCubit>().state.carType;
    final cubit = context.read<CarCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Type Title
        Text(
          TextManager.carType.tr(),
          style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 0.02.sh),

        // Car Type List
        SizedBox(
          height: 0.05.sh,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: carTypes.length,
            separatorBuilder: (_, __) => SizedBox(width: 0.03.sw),
            itemBuilder: (context, index) {
              final type = carTypes[index];
              final isSelected = selected == type.label;

              return GestureDetector(
                onTap: () => cubit.setCarType(type.label),
                // Car Type Container
                child: ReusableContainer(
                  isSelected: isSelected,
                  option: Row(
                    children: [
                      SizedBox(width: 0.01.sw),

                      // Icon and Label
                      Icon(
                        type.icon,
                        size: 20.sp,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSecondary,
                      ),

                      SizedBox(width: 0.01.sw),

                      Text(
                        type.label,
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
