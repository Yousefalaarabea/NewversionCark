import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cark.dart';
import 'core/utils/my_bloc_oserver.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await NotificationService().init();
  
  // Initialize AuthCubit and load user data
  final authCubit = AuthCubit();
  await authCubit.loadUserData();
  
  // Check if user is logged in
  if (authCubit.userModel != null) {
    print('User is logged in: ${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}');
    print('User ID: ${authCubit.userModel!.id}');
    await authCubit.saveFcmToken();
  } else {
    print('No user logged in. User needs to login first.');
  }

  runApp(Cark(authCubit: authCubit));
}

