import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart'; // This import is not used in the provided snippet, but keeping it
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0.05.sw,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Field
            CustomTextFormField(
              controller: widget.emailController,
              prefixIcon: Icons.person,
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
            // Display backend email error separately
            if (_backendErrors['email'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text(
                  _backendErrors['email']!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            SizedBox(height: 0.02.sh),

            // Password Field
            CustomTextFormField(
              controller: widget.passwordController,
              prefixIcon: Icons.lock,
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
            // Display backend password error separately (if your backend sends it)
            if (_backendErrors['password'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text(
                  _backendErrors['password']!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // Handle general errors like 'detail' or 'non_field_errors'
            // This will display "No active account found with the given credentials"
            if (_backendErrors['detail'] != null || _backendErrors['non_field_errors'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 16.0),
                child: Text(
                  _backendErrors['detail'] ?? _backendErrors['non_field_errors']!, // Display 'detail' if present, otherwise 'non_field_errors'
                  style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),


            SizedBox(height: 0.05.sh),

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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return CustomElevatedButton(
                  text: TextManager.loginText,
                  onPressed: () {
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}