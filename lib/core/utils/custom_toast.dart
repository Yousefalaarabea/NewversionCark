import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/themes/app_colors.dart';

void showCustomToast(String msg , bool isError) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? AppColors.red : Colors.green,
      textColor: AppColors.white,
      fontSize: 16.0.sp,
  );
}
