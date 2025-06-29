import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/text_manager.dart';

class ApplyButton extends StatelessWidget {
  const ApplyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 0.015.sh),
        ),
        onPressed: () {
          // Handle Apply button action
        },
        child: Text(
          TextManager.applyButton.tr(),
          style: TextStyle(
              color: Colors.white,
              fontSize: 0.045.sw,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
