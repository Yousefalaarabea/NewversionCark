import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// DONE
class DottedInstructionBox extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const DottedInstructionBox({super.key, required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    final instructions = text.split('\n').where((e) => e.trim().isNotEmpty).toList();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 0.01.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Add a subtle shadow
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.transparent,
          width: 0,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top border (primary color)
          // This is a thin line at the top
          Container(
            width: double.infinity,
            height: 0.01.sh,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          // Instructions text with dots
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), // Extra top padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: instructions.map((line) => Padding(
                padding: EdgeInsets.symmetric(vertical: 0.01.sh),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7, right: 10),
                      width: 0.02.sw,
                      height: 0.01.sh,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        line.trim(),
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}