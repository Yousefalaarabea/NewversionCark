import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/text_manager.dart';


///DONE
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      TextManager.personalInformation.tr(),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      // textAlign: TextAlign.center,
    );
  }
}
