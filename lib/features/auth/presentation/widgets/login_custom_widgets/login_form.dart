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

/// DONE
class LoginForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0.05.sw,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email Field
            CustomTextFormField(
              controller: emailController,
              prefixIcon: Icons.person,
              hintText: TextManager.emailHint.tr(),
            ),

            SizedBox(height: 0.02.sh),

            // Password Field
            CustomTextFormField(
              controller: passwordController,
              prefixIcon: Icons.lock,
              hintText: TextManager.passwordHint.tr(),
            ),

            SizedBox(height: 0.05.sh),

            // Login Button
            BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if(state is LoginSuccess) {
                  showCustomToast(state.message, false);
                  Navigator.pushReplacementNamed(context, ScreensName.homeScreen);
                } else if (state is LoginFailure) {
                  showCustomToast(state.error, true);
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
                    if (formKey.currentState!.validate()) {
                      authCubit.login(
                        email: emailController.text,
                        password: passwordController.text,
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
