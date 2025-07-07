import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import '../../widgets/profile_custom_widgets/edit_profile_form.dart';
import '../../widgets/signup_custom_widgets/signup_form.dart';
import 'dart:io';

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
  late String _initialFirstName;
  late String _initialLastName;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialNationalId;

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
    _initialFirstName = user?.firstName ?? '';
    _initialLastName = user?.lastName ?? '';
    _initialEmail = user?.email ?? '';
    _initialPhone = user?.phoneNumber ?? '';
    _initialNationalId = user?.national_id ?? '';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Image.asset(
                      'assets/images/signup/Cark(signUp).png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  'Edit Information',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Name', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextFormField(
                      controller: _firstnameController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('National ID', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextFormField(
                      controller: _nationalIdController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.credit_card),
                        border: InputBorder.none,
                        hintText: 'Enter your national ID',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Email', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        border: InputBorder.none,
                        hintText: 'Enter your email',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Phone Number', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.phone),
                        border: InputBorder.none,
                        hintText: 'Enter your phone number',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is UpdateProfileSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      } else if (state is UpdateProfileFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                        );
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        ),
                        onPressed: state is UpdateProfileLoading
                            ? null
                            : () {
                                final Map<String, String> changedFields = {};
                                if (_firstnameController.text.trim() != _initialFirstName) {
                                  changedFields['first_name'] = _firstnameController.text.trim();
                                }
                                if (_lastnameController.text.trim() != _initialLastName) {
                                  changedFields['last_name'] = _lastnameController.text.trim();
                                }
                                if (_emailController.text.trim() != _initialEmail) {
                                  changedFields['email'] = _emailController.text.trim();
                                }
                                if (_phoneController.text.trim() != _initialPhone) {
                                  changedFields['phone_number'] = _phoneController.text.trim();
                                }
                                // Don't send national_id, it's read-only
                                if (changedFields.isNotEmpty) {
                                  context.read<AuthCubit>().updateUserProfileWithMap(changedFields);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No changes to update'), backgroundColor: Colors.orange),
                                  );
                                }
                              },
                        icon: state is UpdateProfileLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.edit, size: 22),
                        label: const Text('Edit Profile', style: TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
