import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import '../../widgets/profile_custom_widgets/edit_profile_form.dart';
import '../../widgets/signup_custom_widgets/signup_form.dart';

/// DONE
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;

  @override
  void initState() {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.userModel;
    _formKey = GlobalKey<FormState>();
    _firstnameController = TextEditingController(text: user?.firstName);
    _lastnameController = TextEditingController(text: user?.lastName);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _nationalIdController = TextEditingController(text: user?.national_id);

    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

// Edit Profile
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 0.08.sw, vertical: 0.02.sh),
            child: EditProfileForm(
              formKey: _formKey,
              firstnameController: _firstnameController,
              lastnameController: _lastnameController,
              emailController: _emailController,
              phoneController: _phoneController,
              nationalIdController: _nationalIdController,
            ),
          ),
        ),
      ),
    );
  }
}
