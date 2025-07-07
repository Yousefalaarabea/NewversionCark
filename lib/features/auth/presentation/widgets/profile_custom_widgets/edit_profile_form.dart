import 'dart:developer';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/custom_toast.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';
import '../../cubits/auth_cubit.dart';
import 'id_image_widgets.dart';
import 'licence_image_widget.dart';

///DONE
class EditProfileForm extends StatelessWidget {
  const EditProfileForm(
      {super.key,
      required this.formKey,
      required this.firstnameController,
      required this.lastnameController,
      required this.emailController,
      required this.phoneController,
      required this.nationalIdController});

  final GlobalKey<FormState> formKey;
  final TextEditingController firstnameController;
  final TextEditingController lastnameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nationalIdController;

  String? _validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return TextManager.emailInvalid.tr();
    return null;
  }

  // Phone Number Validator
  String? _validatePhone(String value) {
    final phoneRegex = RegExp(r'^01[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) return TextManager.phoneInvalid.tr();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit Profile
          Text(
            TextManager.editProfileText.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 0.02.sh),

          // First Name Field
          CustomTextFormField(
            controller: firstnameController,
            prefixIcon: Icons.person,
            hintText: TextManager.firstNameHint,
          ),

          SizedBox(height: 0.02.sh),

          // Last Name Field
          CustomTextFormField(
            controller: lastnameController,
            prefixIcon: Icons.person,
            hintText: TextManager.lastNameHint,
          ),

          SizedBox(height: 0.02.sh),

          // Email Field
          CustomTextFormField(
            controller: emailController,
            prefixIcon: Icons.email,
            hintText: TextManager.emailHint,
            validator: _validateEmail,
          ),

          SizedBox(height: 0.02.sh),

          // Phone Number Field
          CustomTextFormField(
            controller: phoneController,
            prefixIcon: Icons.phone,
            hintText: TextManager.phoneHint,
            validator: _validatePhone,
          ),

          SizedBox(height: 0.02.sh),

          // NID Number Field
          CustomTextFormField(
            controller: nationalIdController,
            prefixIcon: Icons.perm_identity,
            hintText: TextManager.nationalIdHint,
            // validator: _validatePassword,
          ),

          // SizedBox(height: 0.03.sh),
          //
          // // Upload ID Image
          // const IdImageWidgets(),
          //
          // SizedBox(height: 0.03.sh),
          //
          // // Upload Licence Image Button
          // const LicenceImageWidget(),
          //
           SizedBox(height: 0.03.sh),

          // Signup Button
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is EditProfileSuccess) {
                showCustomToast(state.message, false);
              } else if (state is EditProfileFailure) {
                showCustomToast(state.error, true);
              }
            },
            builder: (context, state) {
              final authCubit = context.read<AuthCubit>();
              if (state is EditProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return CustomElevatedButton(
                text: TextManager.edit,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    authCubit.editProfile(
                      firstname: firstnameController.text,
                      lastname: lastnameController.text,
                      email: emailController.text,
                      phoneNumber: phoneController.text,
                      national_id: nationalIdController.text,
                      // idImage: authCubit.idImage,
                      // licenceImage: authCubit.licenceImage,
                    );
                  } else {
                    log('Form is not valid');
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
