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
import 'features/home/presentation/cubit/trip_cubit.dart';
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
              BlocProvider(
                create: (context) => TripCubit(),
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
              initialRoute: ScreensName.login // Initial screen

            ),
          );
        },
      ),
    );
  }
}

/// to run car rental options screen directly without need to login or signup
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:test_cark/config/themes/light_theme.dart';
// import 'package:test_cark/features/home/presentation/model/car_model.dart';
// import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
// import 'package:test_cark/features/auth/presentation/cubits/document_cubit.dart';
// import 'package:test_cark/features/shared/cubit/navigation_cubit.dart';
// import 'features/cars/presentation/cubits/add_car_cubit.dart';
// import 'features/cars/presentation/screens/car_rental_options_screen.dart';
// import 'features/handover/handover/presentation/cubits/contract_upload_cubit.dart';
// import 'features/handover/handover/presentation/cubits/handover_cubit.dart';
// import 'features/handover/handover/presentation/cubits/owner_drop_off_cubit.dart';
// import 'features/handover/handover/presentation/cubits/renter_drop_off_cubit.dart';
// import 'features/handover/handover/presentation/cubits/renter_handover_cubit.dart';
// import 'features/home/presentation/cubit/booking_cubit.dart';
// import 'features/home/presentation/cubit/car_cubit.dart';
// import 'features/notifications/presentation/cubits/notification_cubit.dart';
//
// class Cark extends StatelessWidget {
//   const Cark({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return EasyLocalization(
//       supportedLocales: const [Locale('en'), Locale('ar')],
//       path: "assets/translation",
//       fallbackLocale: const Locale('en'),
//       child: ScreenUtilInit(
//         minTextAdapt: true,
//         splitScreenMode: true,
//         designSize: const Size(412, 917),
//         builder: (context, child) {
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(create: (context) => AuthCubit()),
//               BlocProvider(create: (context) => NavigationCubit()),
//               BlocProvider(create: (context) => CarCubit()),
//               BlocProvider(create: (context) => BookingCubit()),
//               BlocProvider(create: (context) => AddCarCubit()),
//               BlocProvider(create: (context) => DocumentCubit()),
//               BlocProvider(create: (context) => NotificationCubit()),
//               BlocProvider(create: (context) => ContractUploadCubit()),
//               BlocProvider(create: (context) => HandoverCubit()),
//               BlocProvider(create: (context) => OwnerDropOffCubit()),
//               BlocProvider(create: (context) => RenterDropOffCubit()),
//               BlocProvider(create: (context) => RenterHandoverCubit()),
//             ],
//             child: MaterialApp(
//               navigatorKey: navigatorKey,
//               localizationsDelegates: context.localizationDelegates,
//               supportedLocales: context.supportedLocales,
//               locale: context.locale,
//               title: 'Cark',
//               debugShowCheckedModeBanner: false,
//               theme: lightTheme,
//               themeMode: ThemeMode.light,
//
//               // ✅ بدل initialRoute استخدم home مباشرة لتجربة UI
//               home: CarRentalOptionsScreen(
//                 carData: CarModel.mock(),
//               ),
//
//               // ❌ علّقي السطر دا مؤقتًا
//               // onGenerateRoute: RoutesManager.onGenerateRoute,
//               // initialRoute: ScreensName.signup,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
///////////////////////////////////////////////////////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// // تأكد من مسارات الاستيراد الصحيحة لملفاتك
// import 'package:test_cark/features/home/presentation/model/car_model.dart'; // مسار CarModel
// import 'package:test_cark/features/home/presentation/model/location_model.dart';
//
// import 'features/home/presentation/screens/booking_screens/trip_management_screen.dart'; // مسار LocationModel
//
// void main() {
//   // قم بتهيئة ScreenUtil هنا إذا كنت تستخدمه في التطبيق بالكامل
//   // WidgetsFlutterBinding.ensureInitialized();
//   // await ScreenUtil.ensureInitialized();
//
//   runApp(const Cark());
// }
//
// class Cark extends StatelessWidget {
//   const Cark({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // بيانات وهمية لاختبار UI فقط
//     // Mock CarModel
//     final mockCar = CarModel(
//       ownerId: 'owner123',
//       // required
//       id: 1,
//       // Changed to int
//       model: 'Camry',
//       // required
//       brand: 'Toyota',
//       // required
//       carType: 'Sedan',
//       // required - example
//       carCategory: 'Standard',
//       // required - example
//       plateNumber: 'ABC 123',
//       // required
//       year: 2022,
//       // required
//       color: 'Red',
//       // required
//       seatingCapacity: 5,
//       // required
//       transmissionType: 'Automatic',
//       // required - example
//       fuelType: 'Gasoline',
//       // required - example
//       currentOdometerReading: 15000,
//       // required
//       availability: true,
//       // required
//       currentStatus: 'Available',
//       // required - example
//       approvalStatus: true,
//       // required
//       // imageUrl: 'https://example.com/car_image.jpg', // Optional, if you want a specific image
//       // driverName, driverRating, driverTrips, kmLimitPerDay, waitingHourCost, extraKmRate are optional
//
//       rentalOptions: RentalOptions(
//         // Required now
//         availableWithoutDriver: true,
//         availableWithDriver: false,
//         dailyRentalPrice: 50.0, // Now part of RentalOptions
//         // monthlyRentalPrice and yearlyRentalPrice can also be set here if needed
//         // dailyRentalPriceWithDriver, monthlyPriceWithDriver, yearlyPriceWithDriver can be set here if needed
//       ),
//       // location: LocationModel(...) // Removed as it's not in your CarModel definition
//     );
//
// // Mock Stops - LocationModel
//     final mockStops = [
//       LocationModel(
//         name: 'Pickup Location: Downtown Cairo',
//         address: '123 Main St, Downtown Cairo',
//         lat: 30.0444,
//         lng: 31.2357,
//       ),
//       LocationModel(
//         name: 'Stop 1: Giza Pyramids',
//         address: 'Giza Pyramids Complex, Giza',
//         lat: 29.9792,
//         lng: 31.1342,
//       ),
//       LocationModel(
//         name: 'Drop-off: Cairo Airport',
//         address: 'Cairo International Airport',
//         lat: 30.1219,
//         lng: 31.4056,
//       ),
//     ];
//
//     const mockTotalPrice = 150.0; // سعر إجمالي وهمي
//
//     return ScreenUtilInit(
//       designSize: const Size(360, 690), // استخدم تصميمك الأساسي لـ ScreenUtil
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (_, child) {
//         return MaterialApp(
//           title: 'Trip Management UI Test',
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//             primarySwatch: Colors.blue,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           // هنا يتم توجيه التطبيق مباشرة لشاشتك
//           home: TripManagementScreen(
//             car: mockCar,
//             totalPrice: mockTotalPrice,
//             stops: mockStops,
//           ),
//         );
//       },
//     );
//   }
// }
