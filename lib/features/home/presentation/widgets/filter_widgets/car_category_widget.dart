import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/widgets/home_widgets/reusable_container.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../cubit/car_cubit.dart';
// Done
class CarCategoryWidget extends StatelessWidget {
  const CarCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = CarCubit.carCategories;
    final selected = context.watch<CarCubit>().state.category;
    final cubit = context.read<CarCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Category Title
        Text(
          TextManager.carCategory.tr(),
          style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 0.01.sh),

        // Car Category List
        SizedBox(
          height: 0.05.sh,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,

            // Space between items
            separatorBuilder: (_, __) => SizedBox(width: 0.03.sw),

            // Item Builder
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selected == category.label;

              return GestureDetector(
                onTap: () => cubit.setCategory(category.label),

                // Category Container
                child:  ReusableContainer(isSelected: isSelected, option: Row(
                  children: [
                    SizedBox(width: 0.01.sw),

                    Icon(
                      category.icon,
                      size: 20.sp,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),

                    SizedBox(width: 0.01.sw),

                    Text(
                      category.label,
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
