import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import '../../cubit/car_cubit.dart';


class DriverFilterSelector extends StatelessWidget {
  const DriverFilterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final withDriver = context.watch<CarCubit>().state.withDriver;
    final cubit = context.read<CarCubit>();

    return Row(
      children: [
        // ChoiceChip for selecting "With Driver"
        ChoiceChip(
          // shows the icon and text for "With Driver"
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person,
                size: 18,
                color: withDriver == true
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                TextManager.withDriver.tr(),
                style: TextStyle(
                  color: withDriver == true
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),

          // toggles the driver filter when selected
          selected: withDriver == true,
          // onSelected: (_) => context.read<CarCubit>().toggleDriver(true),
          onSelected: (_) {
            if (withDriver != true) {
              cubit.setFilters(
                withDriver: true,
                withoutDriver: false,
              );
            }
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          showCheckmark: false,

          // styles the chip with rounded corners and a border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: withDriver == true
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondaryFixedVariant,
            ),
          ),

          // adds padding around the label
          labelPadding:
              EdgeInsets.symmetric(horizontal: 0.02.sw, vertical: 0.01.sh),
        ),

        SizedBox(width: 0.02.sw),

        // ChoiceChip for selecting "Without Driver"
        ChoiceChip(
          // shows the icon and text for "Without Driver"
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off,
                size: 18,
                color: withDriver == false
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                TextManager.withoutDriver.tr(),
                style: TextStyle(
                  color: withDriver == false
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),

          // toggles the driver filter when selected
          selected: withDriver == false,
          // onSelected: (_) => context.read<CarCubit>().toggleDriver(false),
          onSelected: (_) {
            if (withDriver != false) {
              cubit.setFilters(
                withDriver: false,
                withoutDriver: true,
              );
            }
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: withDriver == false
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondaryFixedVariant,
            ),
          ),

          // adds padding around the label
          labelPadding:
              EdgeInsets.symmetric(horizontal: 0.02.sw, vertical: 0.01.sh),
        ),
      ],
    );
  }
}
