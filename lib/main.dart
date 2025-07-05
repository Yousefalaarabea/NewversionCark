import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cark.dart';
import 'core/utils/my_bloc_oserver.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(); // Keep Firebase for Firestore
  await EasyLocalization.ensureInitialized();
  Bloc.observer = MyBlocObserver();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: "assets/translation",
      fallbackLocale: const Locale('en'),
      child: Cark(),
    ),
  );
}

