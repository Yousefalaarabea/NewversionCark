import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cark.dart';
import 'core/utils/my_bloc_oserver.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  await EasyLocalization.ensureInitialized();
  Bloc.observer = MyBlocObserver();

  // Initialize NotificationService (FCM setup, permissions, token send)
  await NotificationService().init();

  // Handle notification tap when app is terminated (deep linking)
  await NotificationService().handleInitialMessage();

  // Optionally: Save FCM token to backend after login (see NotificationService for details)
  // final authCubit = AuthCubit();
  // await authCubit.saveFcmToken();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: "assets/translation",
      fallbackLocale: const Locale('en'),
      child: Cark(),
    ),
  );
}

