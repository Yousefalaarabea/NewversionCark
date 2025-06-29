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
  
  // Initialize FCM token saving for current user
  final authCubit = AuthCubit();
  await authCubit.saveFcmToken();
  
  runApp(const Cark());
}

