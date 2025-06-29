import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/cubit/car_cubit.dart';
import 'package:test_cark/features/home/presentation/cubit/choose_car_state.dart';



class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, ChooseCarState>(
      builder: (context, state) {
        final dateRange = state.dateRange;
        final isDateEmpty = dateRange == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  context.read<CarCubit>().setDateRange(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (isDateEmpty && state.showValidation)
                        ? Colors.red.shade300 
                        : Theme.of(context).colorScheme.onSecondaryFixed,
                    width: (isDateEmpty && state.showValidation) ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today, 
                      size: 20, 
                      color: (isDateEmpty && state.showValidation)
                          ? Colors.red 
                          : Theme.of(context).colorScheme.primary
                    ),
                    SizedBox(width: 0.03.sw),
                    Text(
                      dateRange != null
                          ? '${DateFormat('MMM dd | hh:mm a').format(dateRange.start)} - ${DateFormat('MMM dd | hh:mm a').format(dateRange.end)}'
                          : 'Select rental date range *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: (isDateEmpty && state.showValidation) ? Colors.red : null,
                      ),
                    ),
                  ],
                )
              ),
            ),
            if (isDateEmpty && state.showValidation) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Date range is required',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
