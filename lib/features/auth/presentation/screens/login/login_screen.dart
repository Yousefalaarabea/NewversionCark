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

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  
  // Animation controllers
  late AnimationController _carAnimationController;
  late Animation<double> _carAnimation;
  late Animation<double> _carScaleAnimation;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    
    // Initialize car animation
    _carAnimationController = AnimationController(
      duration: Duration(milliseconds: 4000), // مدة أطول للحركة البطيئة
      vsync: this,
    );
    
    _carAnimation = Tween<double>(
      begin: -200.0, // تبدأ من أقصى اليسار (خارج الشاشة)
      end: 0.0,      // تنتهي عند موقع الشعار
    ).animate(CurvedAnimation(
      parent: _carAnimationController,
      curve: Curves.easeInOut, // حركة سلسة ومريحة
    ));
    
    _carScaleAnimation = Tween<double>(
      begin: 0.8, // تبدأ بحجم أصغر قليلاً
      end: 1.0,   // تنتهي بالحجم الطبيعي
    ).animate(CurvedAnimation(
      parent: _carAnimationController,
      curve: Curves.easeOut, // تأثير حجم سلس
    ));
    
    // بدء الرسوم المتحركة بعد تأخير قصير
    Future.delayed(Duration(milliseconds: 1000), () { // تأخير أطول
      if (mounted) {
        _carAnimationController.forward();
      }
    });
    
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _carAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top spacing
                SizedBox(height: 40.h),
                
                // Logo Section
                _buildLogoSection(),
                
                SizedBox(height: 40.h),
                
                // Welcome Text
                _buildWelcomeSection(),
                
                SizedBox(height: 32.h),
                
                // Login Form
                LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  formKey: _formKey,
                ),
                
                SizedBox(height: 24.h),
                
                // Signup Link
                const AuthOptionsText(
                  text1: TextManager.noAccountQuestion,
                  text2: TextManager.signUpText,
                  screenName: ScreensName.signup,
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // صف الشعارات مع الرسوم المتحركة
        AnimatedBuilder(
          animation: _carAnimation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار السيارة مع الرسوم المتحركة
                Transform.translate(
                  offset: Offset(_carAnimation.value, 0),
                  child: Transform.scale(
                    scale: _carScaleAnimation.value,
                    child: Image.asset(
                      AssetsManager.carSignUp,
                      height: 80.h,
                      width: 80.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                // شعار Cark (ثابت)
                Image.asset(
                  AssetsManager.carkSignUp,
                  height: 80.h,
                  width: 80.w,
                  fit: BoxFit.contain,
                ),
              ],
            );
          },
        ),
        SizedBox(height: 16.h),
        // Tagline
        Text(
          'ride ease reach peace',
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to continue your journey',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
