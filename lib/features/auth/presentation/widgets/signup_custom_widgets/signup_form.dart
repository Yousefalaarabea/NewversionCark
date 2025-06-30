import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../../core/utils/custom_toast.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';
import '../../../../../config/routes/screens_name.dart';
import '../profile_custom_widgets/document_upload_flow.dart';
import '../profile_custom_widgets/licence_image_widget.dart';
import 'id_image_upload_widget.dart';


class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    required this.formKey,
    required this.firstnameController,
    required this.lastnameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.nationalIdController,
    required this.headerText,
  });

  final String headerText;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstnameController;
  final TextEditingController lastnameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController nationalIdController;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  Map<String, String?> fieldErrors = {};

  // Email Validator
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

  // Password Validator
  String? _validatePassword(String value) {
    if (value.length < 6) return TextManager.passwordTooShort.tr();
    return null;
  }

  // National ID Validator
  String? _validateNationalId(String value) {
    final nationalIdRegex = RegExp(
        r"^([23])\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])(0[1-4]|1[1-9]|2[1-9]|3[1-5]|88)\d{5}$");
    if (!nationalIdRegex.hasMatch(value))
      return TextManager.nationalIdInvalid.tr();
    return null;
  }

  void _handleBackendError(String error) {
    try {
      final Map<String, dynamic> errorMap = jsonDecode(error);
      setState(() {
        fieldErrors = errorMap.map((k, v) => MapEntry(k, (v is List && v.isNotEmpty) ? v[0].toString() : v.toString()));
      });
    } catch (_) {
      // If the error is not a JSON, show it as a general toast
      setState(() { fieldErrors.clear(); });
      showCustomToast(error, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Account Text
          Text(
            widget.headerText.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 0.02.sh),

          // First Name Field
          CustomTextFormField(
            controller: widget.firstnameController,
            prefixIcon: Icons.person,
            hintText: TextManager.firstNameHint,
            validator: (value) {
              if (value.trim().isEmpty) {
                return 'Please enter your first name.';
              }
              final nameRegex = RegExp(r'^[A-Za-z\u0600-\u06FF\s]+$');
              if (!nameRegex.hasMatch(value.trim())) {
                return 'Name can only contain letters, Arabic characters, and spaces.';
              }
              return null;
            },
          ),

          if (fieldErrors['first_name'] != null) // Display backend error separately
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Text(
                fieldErrors['first_name']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          SizedBox(height: 0.02.sh),

          // Last Name Field
          CustomTextFormField(
            controller: widget.lastnameController,
            prefixIcon: Icons.person,
            hintText: TextManager.lastNameHint,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name.';
              }
              // Allow letters (English and Arabic) and spaces
              final nameRegex = RegExp(r'^[A-Za-z\u0600-\u06FF\s]+$');
              if (!nameRegex.hasMatch(value)) {
                return 'Name can only contain letters, Arabic characters, and spaces.';
              }
              return null; // Return null if local validation passes
            },
          ),
          if (fieldErrors['last_name'] != null) // Display backend error separately
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Text(
                fieldErrors['last_name']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          SizedBox(height: 0.02.sh),

          // Email Field
          CustomTextFormField(
            controller: widget.emailController,
            prefixIcon: Icons.email,
            hintText: TextManager.emailHint,
            validator: (value) {
              return _validateEmail(value ?? ''); // Only return local validation error
            },
          ),
          if (fieldErrors['email'] != null) // Display backend error separately
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Text(
                fieldErrors['email']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          SizedBox(height: 0.02.sh),

          // Phone Number Field
          CustomTextFormField(
            controller: widget.phoneController,
            prefixIcon: Icons.phone,
            hintText: TextManager.phoneHint,
            validator: (value) {
              return _validatePhone(value ?? ''); // Only return local validation error
            },
          ),
          if (fieldErrors['phone_number'] != null) // Display backend error separately
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Text(
                fieldErrors['phone_number']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          SizedBox(height: 0.02.sh),
          // Password Field
          CustomTextFormField(
            controller: widget.passwordController,
            prefixIcon: Icons.lock,
            hintText: TextManager.passwordHint,
            obscureText: true,
            validator: _validatePassword, // Only return local validation error
            enablePasswordToggle: true,
          ),
          // Note: Password field doesn't have a backend error display in the provided example JSON.
          // If it did, you would add an if (fieldErrors['password'] != null) block here.


          SizedBox(height: 0.02.sh),
          // National ID Field
          CustomTextFormField(
            controller: widget.nationalIdController,
            prefixIcon: Icons.perm_identity,
            hintText: TextManager.nationalIdHint,
            validator: (value) {
              return _validateNationalId(value ?? ''); // Only return local validation error
            },
          ),
          if (fieldErrors['national_id'] != null) // Display backend error separately
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Text(
                fieldErrors['national_id']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          SizedBox(height: 0.03.sh),

          // Removed the commented out custom image pickers for brevity if not actively used.
          // const CustomImagePicker(label: TextManager.upload_your_id,),
          // SizedBox(height: 0.03.sh),
          // const IdImageUploadWidget(),
          // SizedBox(height: 0.03.sh),
          // const LicenceImageWidget(),

          SizedBox(
            height: 0.03.sh,
          ),
          // Signup Button
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is SignUpSuccess) {
                setState(() { fieldErrors.clear(); }); // Clear backend errors on success
                showCustomToast(state.message, false);
                Navigator.pushReplacementNamed(context, ScreensName.rentalSearchScreen);
              } else if (state is SignUpFailure) {
                _handleBackendError(state.error); // Handle backend errors
              }
            },
            builder: (context, state) {
              final authCubit = context.read<AuthCubit>();
              if (state is SignUpLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return CustomElevatedButton(
                text: TextManager.signUpText,
                onPressed: () {
                  // Clear previous backend errors before validating to avoid stale messages
                  setState(() {
                    fieldErrors.clear();
                  });

                  if (widget.formKey.currentState!.validate()) {
                    authCubit.signup(
                      widget.firstnameController.text,
                      widget.lastnameController.text,
                      widget.emailController.text,
                      widget.phoneController.text,
                      widget.passwordController.text,
                      widget.nationalIdController.text,
                    );
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