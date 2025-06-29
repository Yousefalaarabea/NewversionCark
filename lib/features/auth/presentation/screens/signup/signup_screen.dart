import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/utils/text_manager.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../widgets/shared/auth_options_text.dart';
import '../../widgets/signup_custom_widgets/signup_form.dart';

/// DONE
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final _formKey;
  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nationalIdController;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _nationalIdController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          print("✅ BlocListener caught SignUpSuccess");
          Navigator.pushReplacementNamed(context, ScreensName.rentalSearchScreen);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 0.08.sw, vertical: 0.03.sh),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Car Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AssetsManager.carSignUp, height: 0.05.sh),
                      SizedBox(width: 0.02.sw),
                      Image.asset(AssetsManager.carkSignUp, height: 0.03.sh),
                    ],
                  ),

                  SizedBox(height: 0.05.sh),

                  // Signup with name , email , phone number and password
                  SignupForm(
                    formKey: _formKey,
                    firstnameController: _firstnameController,
                    lastnameController: _lastnameController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    passwordController: _passwordController,
                    nationalIdController: _nationalIdController,
                    headerText: TextManager.createAccount,
                  ),

                  SizedBox(height: 0.02.sh),

                  // Signup Or Login
                  const AuthOptionsText(
                    text1: TextManager.alreadyHaveAccount,
                    text2: TextManager.loginText,
                    screenName: ScreensName.login,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
