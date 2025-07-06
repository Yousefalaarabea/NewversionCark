import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/utils/custom_toast.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';
import 'dart:convert';

/// DONE
class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Use a map for field errors and general errors
  Map<String, String?> _backendErrors = {};

  void _handleBackendError(String error) {
    try {
      final Map<String, dynamic> errorMap = jsonDecode(error);
      setState(() {
        _backendErrors.clear(); // Clear previous errors

        errorMap.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            _backendErrors[key] = value[0].toString();
          } else {
            _backendErrors[key] = value.toString();
          }
        });
      });
    } catch (_) {
      // If the error is not a JSON, show it as a general toast
      setState(() { _backendErrors.clear(); }); // Clear specific errors if general error received
      showCustomToast(error, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: CustomTextFormField(
              controller: widget.emailController,
              prefixIcon: Icons.email_outlined,
              hintText: TextManager.emailHint.tr(),
              validator: (value) {
                // Clear the backend email error when the user starts typing/validating locally
                if (_backendErrors['email'] != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) { // Check if widget is still mounted before setState
                      setState(() {
                        _backendErrors['email'] = null;
                      });
                    }
                  });
                }

                if (value == null || value.isEmpty) {
                  return TextManager.fieldIsRequired.tr();
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value)) {
                  return TextManager.emailInvalid.tr();
                }
                return null; // Only return null if local validation passes
              },
            ),
          ),
          // Display backend email error separately
          if (_backendErrors['email'] != null)
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.h),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      _backendErrors['email']!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 20.h),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: CustomTextFormField(
              controller: widget.passwordController,
              prefixIcon: Icons.lock_outline,
              hintText: TextManager.passwordHint.tr(),
              obscureText: true,
              enablePasswordToggle: true,
              validator: (value) {
                // Clear the backend password error when the user starts typing/validating locally
                if (_backendErrors['password'] != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) { // Check if widget is still mounted before setState
                      setState(() {
                        _backendErrors['password'] = null;
                      });
                    }
                  });
                }

                if (value == null || value.isEmpty) {
                  return TextManager.fieldIsRequired.tr();
                }
                if (value.length < 6) {
                  return TextManager.passwordTooShort.tr();
                }
                return null; // Only return null if local validation passes
              },
            ),
          ),
          // Display backend password error separately (if your backend sends it)
          if (_backendErrors['password'] != null)
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.h),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      _backendErrors['password']!,
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),

          // Handle general errors like 'detail' or 'non_field_errors'
          // This will display "No active account found with the given credentials"
          if (_backendErrors['detail'] != null || _backendErrors['non_field_errors'] != null)
            Container(
              margin: EdgeInsets.only(top: 16.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _backendErrors['detail'] ?? _backendErrors['non_field_errors']!,
                      style: TextStyle(color: Colors.red[700], fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 32.h),

          // Login Button
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if(state is LoginSuccess) {
                setState(() { _backendErrors.clear(); }); // Clear all backend errors on success
                showCustomToast(state.message, false);
                Navigator.pushReplacementNamed(context, ScreensName.rentalSearchScreen);
              } else if (state is LoginFailure) {
                _handleBackendError(state.error); // Handle backend errors
              }
            },
            builder: (context, state) {
              final authCubit = context.read<AuthCubit>();
              if (state is LoginLoading) {
                return Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                );
              }
              return Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      // Clear previous backend errors before validating to avoid stale messages
                      setState(() {
                        _backendErrors.clear();
                      });

                      if (widget.formKey.currentState!.validate()) {
                        authCubit.login(
                          email: widget.emailController.text,
                          password: widget.passwordController.text,
                        );
                      }
                    },
                    child: Center(
                      child: Text(
                        TextManager.loginText.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}