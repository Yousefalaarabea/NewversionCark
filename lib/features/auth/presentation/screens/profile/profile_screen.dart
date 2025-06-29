import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../cubits/auth_cubit.dart';
import '../../models/user_model.dart';
import '../../widgets/profile_custom_widgets/editable_info.dart';
import '../../widgets/profile_custom_widgets/profile_header.dart';
import '../../widgets/profile_custom_widgets/profile_picture.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  // final UserModel userModel;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final userModel = context.read<AuthCubit>().userModel;
        
        // Combine first name and last name for display
        final fullName = '${userModel?.firstName ?? ''} ${userModel?.lastName ?? ''}'.trim();

        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileHeader(),
          
                  SizedBox(height: 0.02.sh),
          
                  // Profile Picture
                  const ProfilePicture(),
          
                  SizedBox(height: 0.02.sh),
          
                  // User Information
                  Expanded(
                    child: ListView(
                      children: [
                        EditableInfo(title: TextManager.nameHint, value: fullName),
                        EditableInfo(title: TextManager.emailHint, value: userModel?.email ?? ''),
                        EditableInfo(title: TextManager.phoneHint, value: userModel?.phoneNumber ?? ''),
                        EditableInfo(title: TextManager.nationalIdHint, value: userModel?.national_id ?? ''),
                      ],
                    ),
                  ),
          
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                      child: Text(
                        TextManager.edit.tr(),
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
