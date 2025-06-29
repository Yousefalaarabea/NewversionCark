import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/styles_manager.dart';

class CarDetailSection extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> details;

  const CarDetailSection({
    super.key,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: StylesManager.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: StylesManager.titleStyle),
            SizedBox(height: 8.h),
            ...details.map(
              (detail) => Padding(
                padding: StylesManager.detailRowPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140.w,
                      child: Text(
                        detail.key,
                        style: StylesManager.labelStyle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail.value,
                        style: StylesManager.valueStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 