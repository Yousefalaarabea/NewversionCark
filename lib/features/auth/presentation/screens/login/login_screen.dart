import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/core/utils/assets_manager.dart';
import '../../../../../core/utils/text_manager.dart';
import '../../widgets/shared/auth_options_text.dart';
import '../../widgets/login_custom_widgets/login_form.dart';
import '../../widgets/login_custom_widgets/login_header.dart';

/// DONE
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;

  late final TextEditingController _passwordController;

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoginHeader(),

              // Login form
              LoginForm(
                emailController: _emailController,
                passwordController: _passwordController,
                formKey: _formKey,
              ),

              SizedBox(height: 0.02.sh),

              // Signup or login
              const AuthOptionsText(
                text1: TextManager.noAccountQuestion,
                text2: TextManager.signUpText,
                screenName: ScreensName.signup,
              ),

              SizedBox(height: 0.2.sh),

              // Car Image
              Image.asset(
                AssetsManager.carLoginScreen,
                width: screenWidth,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
