import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Done
class ReusableContainer extends StatelessWidget {
  ReusableContainer({
    super.key,
    required this.isSelected,
    required this.option,
  });

  bool isSelected;
  Widget option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.03.sw, vertical: 0.010.sh),

      // Container decorations ( padding, border radius, color)
      decoration: BoxDecoration(
        // Background color changes based on selection
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSecondaryContainer,

        borderRadius: BorderRadius.circular(10),

        // Border color changes based on selection
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSecondaryFixedVariant,
        ),
      ),

      // Show category name in the center of the container
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            // Text color changes based on selection
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSecondary,

            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),

          // Display the option widget (icon and text)
          child: option,
        ),
      ),
    );
  }
}
