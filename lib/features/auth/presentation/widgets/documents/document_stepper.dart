import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///DONE
// This widget displays a horizontal stepper for document steps in a process.
class DocumentStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final ThemeData theme;

  const DocumentStepper(
      {super.key,
      required this.totalSteps,
      required this.currentStep,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps * 2 - 1, (index) {
          // Even index for steps, odd index for dots
          if (index.isEven) {
            int step = index ~/ 2;
            Color color;
            Color textColor;
            if (step <= currentStep) {
              color = theme.primaryColor;
              textColor = Theme.of(context).colorScheme.onPrimary;
            } else {
              color = Theme.of(context).colorScheme.onSecondaryFixedVariant;
              textColor = Theme.of(context).colorScheme.onPrimary;
            }
            // Return a CircleAvatar for the step
            return CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            // Dots between steps
            int leftStep = (index - 1) ~/ 2;
            Color dotColor = (leftStep < currentStep)
                ? theme.primaryColor
                : Theme.of(context).colorScheme.onSecondaryFixedVariant;

            // Return a small dot
            return Row(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.01.sw),
                  child: Container(
                    width: 0.02.sw,
                    height: 0.02.sh,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
