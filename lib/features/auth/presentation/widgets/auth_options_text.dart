import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "${text1.tr()} ",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 0.04.sw,
              ),
            ),
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, screenName);
                },
              text: text2.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
