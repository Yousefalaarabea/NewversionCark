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
        final fullName = '${userModel?.firstName ?? ''} ${userModel?.lastName ?? ''}'.trim();

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Column(
                    children: [
                  const ProfilePicture(),
                      const SizedBox(height: 18),
                    ],
                  )),
                  Text(
                    'My Information',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Name', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  _ProfileInfoCard(
                    icon: Icons.person,
                    value: fullName,
                  ),
                  const SizedBox(height: 16),
                  const Text('National ID', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  _ProfileInfoCard(
                    icon: Icons.credit_card,
                    value: userModel?.national_id ?? '',
                  ),
                  const SizedBox(height: 16),
                  const Text('Email', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  _ProfileInfoCard(
                    icon: Icons.email,
                    value: userModel?.email ?? '',
                  ),
                  const SizedBox(height: 16),
                  const Text('Phone Number', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  _ProfileInfoCard(
                    icon: Icons.phone,
                    value: userModel?.phoneNumber ?? '',
                    ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                      child: const Text('Edit Profile', style: TextStyle(fontSize: 16)),
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

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  const _ProfileInfoCard({required this.icon, required this.value});
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 18),
            Expanded(
              child: Text(value, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
