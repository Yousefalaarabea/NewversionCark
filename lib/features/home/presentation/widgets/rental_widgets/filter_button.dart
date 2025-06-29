import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import '../../../../../core/utils/text_manager.dart';

// This widget is a button that navigates to the filter screen when tapped.
class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ScreensName.filterScreen);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0.07.sw, vertical: 0.01.sh),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon for filter
            Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),

            SizedBox(
              width: 0.03.sw,
            ),

            // Text for filter
            Text(
              TextManager.filter.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
