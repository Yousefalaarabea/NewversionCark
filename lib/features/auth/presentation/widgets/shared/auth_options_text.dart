import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../config/themes/app_colors.dart';

///DONE
class AuthOptionsText extends StatelessWidget {
  const AuthOptionsText(
      {super.key,
      required this.text1,
      required this.text2,
      required this.screenName});

  final String text1;
  final String text2;
  final String screenName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${text1.tr()} ",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, screenName);
                  },
                text: text2.tr(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                  decorationThickness: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
