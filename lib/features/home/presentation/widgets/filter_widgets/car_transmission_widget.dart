import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/widgets/home_widgets/reusable_container.dart';
import '../../../../../../../core/utils/text_manager.dart';
import '../../cubit/car_cubit.dart';
// Done
class CarTransmissionWidget extends StatelessWidget {
  const CarTransmissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const transmissions = CarCubit.transmissions;
    final selected = context.watch<CarCubit>().state.transmission;
    final cubit = context.read<CarCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transmission Title
        Text(
          TextManager.transmissionTypes.tr(),
          style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 0.01.sh),

        // Transmission List
        SizedBox(
          height: 0.05.sh,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: transmissions.length,
            separatorBuilder: (_, __) => SizedBox(width: 0.03.sw),
            itemBuilder: (context, index) {
              final transmission = transmissions[index];
              final isSelected = selected == transmission.label;

              return GestureDetector(
                onTap: () => cubit.setTransmission(transmission.label),
                // Transmission Container
                child: ReusableContainer(isSelected: isSelected, option: Row(
                  children: [
                    SizedBox(width: 0.01.sw),

                    Icon(
                      transmission.icon,
                      size: 20.sp,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),

                    SizedBox(width: 0.01.sw),

                    Text(
                      transmission.label,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                )),
              );
            },
          ),
        ),
      ],
    );
  }
}
