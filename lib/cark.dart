import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/routes/routes_manager.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/config/themes/light_theme.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:test_cark/features/auth/presentation/cubits/document_cubit.dart';
import 'package:test_cark/features/shared/cubit/navigation_cubit.dart';
import 'features/cars/presentation/cubits/add_car_cubit.dart';
import 'features/handover/handover/presentation/cubits/contract_upload_cubit.dart';
import 'features/handover/handover/presentation/cubits/handover_cubit.dart';
import 'features/handover/handover/presentation/cubits/owner_drop_off_cubit.dart';
import 'features/handover/handover/presentation/cubits/renter_drop_off_cubit.dart';
import 'features/handover/handover/presentation/cubits/renter_handover_cubit.dart';
import 'features/home/presentation/cubit/booking_cubit.dart';
import 'features/home/presentation/cubit/car_cubit.dart';
import 'features/notifications/presentation/cubits/notification_cubit.dart';

class Cark extends StatelessWidget {
  const Cark({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: "assets/translation", // json files
      fallbackLocale: const Locale('en'),
      child: ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        designSize: const Size(412, 917),
        builder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AuthCubit(),
              ),
              BlocProvider(
                create: (context) => NavigationCubit(),
              ),
              BlocProvider(
                create: (context) => CarCubit(),
              ),
              BlocProvider(
                create: (context) => BookingCubit(),
              ),
              BlocProvider(
                create: (context) => AddCarCubit(),
              ),
              BlocProvider(
                create: (context) => DocumentCubit(),
              ),
              BlocProvider(
                create: (context) => NotificationCubit(),
              ),
              BlocProvider(
                create: (context) => ContractUploadCubit(),
              ),
              BlocProvider(
                create: (context) => HandoverCubit(),
              ),
              BlocProvider(
                create: (context) => OwnerDropOffCubit(),
              ),
              BlocProvider(
                create: (context) => RenterDropOffCubit(),
              ),
              BlocProvider(
                create: (context) => RenterHandoverCubit(),
              ),

            ],
            child: MaterialApp(
                navigatorKey: navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              onGenerateRoute: RoutesManager.onGenerateRoute,
              title: 'Cark',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              // darkTheme: ThemeData.dark(),
              themeMode: ThemeMode.light,
              initialRoute: ScreensName.signup // Initial screen
            ),
          );
        },
      ),
    );
  }
}
