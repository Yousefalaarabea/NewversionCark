import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class StylesManager {
  // Text Styles
  static TextStyle get titleStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.blue[800],
  );

  static TextStyle get labelStyle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.grey[700],
  );

  static TextStyle get valueStyle => TextStyle(
    fontSize: 16.sp,
    color: Colors.grey[900],
  );

  static TextStyle get tableHeaderStyle => TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14.sp,
  );

  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get carImageDecoration => BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24.r),
      bottomRight: Radius.circular(24.r),
    ),
  );

  // Button Styles
  static ButtonStyle get deleteButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Paddings
  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);
  static EdgeInsets get tablePadding => EdgeInsets.all(16.w);
  static EdgeInsets get detailRowPadding => EdgeInsets.symmetric(vertical: 8.h);
} 