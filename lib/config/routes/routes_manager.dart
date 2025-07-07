import 'package:flutter/material.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:test_cark/features/auth/presentation/screens/login/login_screen.dart';
import 'package:test_cark/features/auth/presentation/screens/signup/signup_screen.dart';
import 'package:test_cark/features/cars/presentation/screens/view_car_details_screen.dart';
import 'package:test_cark/features/notifications/presentation/screens/new_notifications_screen.dart';
import 'package:test_cark/features/splash/presentation/screens/get_started_screen.dart';
import '../../features/auth/presentation/screens/profile/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/profile/profile_screen.dart';
import '../../features/cars/presentation/screens/add_car_screen.dart';
import '../../features/cars/presentation/screens/car_rental_options_screen.dart';
import '../../features/cars/presentation/screens/car_usage_policy_screen.dart';
import '../../features/cars/presentation/screens/view_cars_screen.dart';
import '../../features/handover/handover/presentation/models/handover_log_model.dart';
import '../../features/handover/handover/presentation/models/post_trip_handover_model.dart';
import '../../features/handover/handover/presentation/screens/handover_screen.dart';
import '../../features/handover/handover/presentation/screens/owner_drop_off_screen.dart';
import '../../features/handover/handover/presentation/screens/renter_handover_screen.dart';
import '../../features/handover/handover/presentation/screens/renter_drop_off_screen.dart';
import '../../features/home/presentation/screens/booking_screens/trip_details_screen.dart';
import '../../features/home/presentation/screens/home_screens/filter_screen.dart';
import '../../features/home/presentation/screens/home_screens/home_screen.dart';
import '../../features/home/presentation/screens/booking_screens/rental_search_screen.dart';
import '../../features/home/presentation/screens/renter/send_request_to_owner_screen.dart';
import '../../features/notifications/presentation/screens/owner_notification_screen.dart';
import '../../features/notifications/presentation/screens/renter_notification_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/booking_screens/booking_summary_screen.dart';
import '../../features/home/presentation/screens/booking_screens/trip_management_screen.dart';
import '../../features/home/presentation/screens/booking_screens/payment_screen.dart';
import '../../features/home/presentation/screens/booking_screens/booking_request_screen.dart';
import '../../features/home/presentation/screens/booking_screens/deposit_payment_screen.dart';
import '../../features/home/presentation/screens/booking_screens/booking_history_screen.dart';
import '../../features/home/presentation/screens/booking_screens/payment_methods_screen.dart';
import '../../features/home/presentation/screens/booking_screens/deposit_input_screen.dart';
import '../../features/home/presentation/model/car_model.dart';
import '../../features/home/presentation/model/location_model.dart';
import '../../features/owner/presentation/screens/owner_home_screen.dart';
import '../../features/home/presentation/screens/booking_screens/trip_details_confirmation_screen.dart';
import '../../features/home/presentation/screens/booking_screens/trip_with_driver_confirmation_screen.dart';
import '../../features/home/presentation/screens/booking_screens/cancel_rental_screen.dart';
import '../../features/home/presentation/screens/owner/owner_trip_request_screen.dart';
import '../../features/home/presentation/screens/booking_screens/renter_ongoing_trip_screen.dart';
import '../../features/home/presentation/model/trip_details_model.dart';
import '../../features/home/presentation/model/trip_with_driver_details_model.dart';
import '../../features/owner/presentation/screens/owner_ongoing_trip_screen.dart';
import '../../features/owner/presentation/screens/live_location_map_screen.dart';
import '../../features/home/presentation/screens/booking_screens/saved_trips_screen.dart';
import '../../features/home/presentation/screens/booking_screens/trip_details_readonly_screen.dart';
import '../../features/home/presentation/screens/booking_screens/test_login_screen.dart';
import '../../features/home/presentation/screens/booking_screens/test_booking_api_screen.dart';
import '../../features/home/presentation/screens/booking_screens/rental_flow_test_screen.dart' as flow_test;
import 'package:test_cark/features/cars/presentation/cubits/add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import '../../features/home/model/car_rental_preview_model.dart';
import '../../features/notifications/presentation/cubits/notification_cubit.dart';

abstract class RoutesManager {
  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    print("in RoutesManager , route settings name: ${routeSettings.name}");
    switch (routeSettings.name) {
      case ScreensName.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case ScreensName.getStarted:
        return MaterialPageRoute(
            builder: (context) => const GetStartedScreen());
      case ScreensName.login:
        return MaterialPageRoute(builder: (context) => (LoginScreen()));
      case ScreensName.signup:
        return MaterialPageRoute(builder: (context) => const SignUpScreen());
      case ScreensName.profile:
        return MaterialPageRoute(builder: (context) => const ProfileScreen());
      case ScreensName.editProfile:
        return MaterialPageRoute(
            builder: (context) => const EditProfileScreen());
      case ScreensName.homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeScreen());

      // case ScreensName.mainNavigationScreen:
      //   return MaterialPageRoute(builder: (context) => MainNavigationScreen());
      case ScreensName.filterScreen:
        return MaterialPageRoute(builder: (context) => const FilterScreen());

      case ScreensName.rentalSearchScreen:
        return MaterialPageRoute(
            builder: (context) => const RentalSearchScreen());


      case ScreensName.bookingSummaryScreen:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final car = args['car'] as CarModel;
        
        // Handle both old and new argument formats
        CarRentalPreviewModel? rentalPreview;
        
        if (args.containsKey('rentalPreview')) {
          // New format with rentalPreview
          rentalPreview = args['rentalPreview'] as CarRentalPreviewModel;
        }
        
        return MaterialPageRoute(
            builder: (context) => BookingSummaryScreen(
                  car: car,
                  rentalPreview: rentalPreview,
                ));

      case ScreensName.tripManagementScreen:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final car = args['car'] as CarModel;
        final totalPrice = args['totalPrice'] as double;
        final stops = args['stops'] as List<dynamic>;
        final tripId = args['tripId'] as String;
        final renterId = args['renterId'] as String;
        final ownerId = args['ownerId'] as String;
        final paymentMethod = args['paymentMethod'] as String;
        return MaterialPageRoute(
            builder: (context) => TripManagementScreen(
                  car: car,
                  totalPrice: totalPrice,
                  stops: stops.cast<LocationModel>(),
                  tripId: tripId,
                  renterId: renterId,
                  ownerId: ownerId,
                  paymentMethod: paymentMethod,
                ));
      case ScreensName.paymentScreen:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final totalPrice = args['totalPrice'] as double;
        final car = args['car'] as CarModel?;
        return MaterialPageRoute(
            builder: (context) => PaymentScreen(
                  totalPrice: totalPrice,
                  car: car,
                ));

      // case ScreensName.ownerNotificationScreen:
      //   return MaterialPageRoute(
      //       builder: (context) => const OwnerNotificationScreen());
      // case ScreensName.renterNotificationScreen:
      //   return MaterialPageRoute(
      //       builder: (context) => const RenterNotificationScreen());

      case ScreensName.showCarDetailsScreen:
        if (routeSettings.arguments is CarModel) {
          return MaterialPageRoute(
            builder: (context) =>
                ViewCarDetailsScreen(carBundle: routeSettings.arguments as CarBundle),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Error: No car data provided')),
          ),
        );

      case ScreensName.viewCarsScreen:
        return MaterialPageRoute(builder: (context) => const ViewCarsScreen());

      // case ScreensName.bookingHistoryScreen:
      //   return MaterialPageRoute(builder: (context) => const BookingHistoryScreen());

      case ScreensName.addCarScreen:
        return MaterialPageRoute(builder: (context) => const AddCarScreen());

      case ScreensName.rentalOptionScreen:
        if (routeSettings.arguments is CarModel) {
          return MaterialPageRoute(
            builder: (context) => CarRentalOptionsScreen(
              carData: routeSettings.arguments as CarModel,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Error: No car data provided'),
            ),
          ),
        );

      case ScreensName.usagePolicyScreen:
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CarUsagePolicyScreen(
              carData: args['car'] as CarModel,
              rentalOptions: args['rentalOptions'] as CarRentalOptions,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Error: Invalid arguments for usage policy screen'),
            ),
          ),
        );

      case ScreensName.ownerHomeScreen:
        return MaterialPageRoute(builder: (context) => const OwnerHomeScreen());

      case ScreensName.renterHandoverScreen:
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          final rentalId = args['rentalId'] as int;
          final notification = args['notification'] as AppNotification;
          return MaterialPageRoute(
            builder: (context) => RenterHandoverScreen(rentalId: rentalId, notification: notification),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Error: Missing rentalId or notification')),
          ),
        );

      case ScreensName.renterDropOffScreen:
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RenterDropOffScreen(
             // tripId: args['tripId'] as String,
              carId: args['carId'] as String,
              //renterId: args['renterId'] as String,
              ownerId: args['ownerId'] as String,
              rentalId: args['rentalId'] as String,
              paymentMethod: args['paymentMethod'] as String,

            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
                child: Text(
                    'Error: Missing required arguments for renter drop-off')),
          ),
        );

      // case ScreensName.handoverScreen:
      //   return MaterialPageRoute(builder: (context) => const HandoverScreen());

      case ScreensName.handoverScreen:
        print('🔍 [RoutesManager] Creating handoverScreen route');
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          print('🔍 [RoutesManager] handoverScreen arguments: $args');
          
          final paymentMethod = args['paymentMethod'] as String? ?? 'unknown';
          final dynamic rawRentalId = args['rentalId'];
          
          print('🔍 [RoutesManager] paymentMethod: $paymentMethod');
          print('🔍 [RoutesManager] rawRentalId: $rawRentalId (type: ${rawRentalId.runtimeType})');
          
          int? rentalId;
          if (rawRentalId is int) {
            rentalId = rawRentalId;
          } else if (rawRentalId is String) {
            rentalId = int.tryParse(rawRentalId);
          } else if (rawRentalId != null) {
            rentalId = int.tryParse(rawRentalId.toString());
          }
          
          print('🔍 [RoutesManager] processed rentalId: $rentalId');
          
          if (rentalId != null) {
            return MaterialPageRoute(
              builder: (context) => HandoverScreen(paymentMethod: paymentMethod, rentalId: rentalId!),
            );
          } else {
            print('❌ [RoutesManager] Invalid rentalId: $rawRentalId');
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Error')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: Invalid rentalId'),
                      Text('Received: $rawRentalId'),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        print('❌ [RoutesManager] Invalid arguments for handoverScreen');
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Error: Missing payment method or rentalId')),
          ),
        );

      case ScreensName.ownerDropOffScreen:
        if (routeSettings.arguments is Map<String, dynamic>) {
          final notification = routeSettings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => OwnerDropOffScreen(
              notificationData: notification,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
                child: Text(
                    'Error: Missing required arguments for owner drop-off')),
          ),
        );
      case ScreensName.tripDetailsScreen:
        return MaterialPageRoute(
          builder: (context) => const TripDetailsScreen(),
        );

      // case ScreensName.bookingRequestScreen:
      //   return MaterialPageRoute(
      //       builder: (context) => const BookingRequestScreen());

      case ScreensName.bookingHistoryScreen:
        return MaterialPageRoute(
            builder: (context) => const BookingHistoryScreen());

      case ScreensName.paymentMethodsScreen:
        print('RoutesManager: Creating paymentMethodsScreen route');
        if (routeSettings.arguments is Map<String, dynamic>) {
        final args = routeSettings.arguments as Map<String, dynamic>;
          print('RoutesManager: Payment methods arguments received: $args');
          
          // Handle both old format (car + totalPrice) and new format (bookingRequestId + bookingData)
          final totalPrice = args['totalPrice'] as double?;
          final car = args['car'] as CarModel?;
          final bookingRequestId = args['bookingRequestId'] as String?;
          final bookingData = args['bookingData'] as Map<String, dynamic>?;
          
          print('RoutesManager: totalPrice: $totalPrice');
          print('RoutesManager: car: $car');
          print('RoutesManager: bookingRequestId: $bookingRequestId');
          print('RoutesManager: bookingData: $bookingData');
          
        return MaterialPageRoute(
          builder: (context) => PaymentMethodsScreen(
            totalPrice: totalPrice,
            car: car,
              bookingRequestId: bookingRequestId,
              bookingData: bookingData,
            ),
          );
        }
        print('RoutesManager: Invalid arguments for paymentMethodsScreen');
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Error: Invalid arguments for payment methods screen'),
            ),
          ),
        );

      // case ScreensName.depositPaymentScreen:
      //   final args = routeSettings.arguments as Map<String, dynamic>;
      //   final car = args['car'] as CarModel;
      //   final totalPrice = args['totalPrice'] as double;
      //   final requestId = args['requestId'] as String?;
      //   final bookingData = args['bookingData'] as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (context) => DepositPaymentScreen(
      //       car: car,
      //       totalPrice: totalPrice,
      //       requestId: requestId,
      //       bookingData: bookingData,
      //     ),
      //   );

      case ScreensName.depositInputScreen:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final car = args['car'] as CarModel;
        final totalPrice = args['totalPrice'] as double;
        final stops = args['stops'] as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) => DepositInputScreen(
            car: car,
            totalPrice: totalPrice,
            stops: stops.cast<LocationModel>(),
          ),
        );

      case ScreensName.tripDetailsConfirmationScreen:
        final args = routeSettings.arguments as TripDetailsModel;
        return MaterialPageRoute(
          builder: (context) =>
              TripDetailsConfirmationScreen(tripDetails: args),
        );
      case ScreensName.tripWithDriverConfirmationScreen:
        final args = routeSettings.arguments as TripWithDriverDetailsModel;
        return MaterialPageRoute(
          builder: (context) =>
              TripWithDriverConfirmationScreen(tripDetails: args),
        );
      case ScreensName.ownerTripRequestScreen:
        print('RoutesManager: Creating ownerTripRequestScreen route');
        if (routeSettings.arguments is Map<String, dynamic>) {
        final args = routeSettings.arguments as Map<String, dynamic>;
          print('RoutesManager: Arguments received: $args');
          
          final bookingRequestId = args['bookingRequestId'] as String? ?? 'unknown';
          final bookingData = args['bookingData'] as Map<String, dynamic>? ?? {};
          
          print('RoutesManager: bookingRequestId: $bookingRequestId');
          print('RoutesManager: bookingData: $bookingData');
          
        return MaterialPageRoute(
          builder: (context) => OwnerTripRequestScreen(
            bookingRequestId: bookingRequestId,
            bookingData: bookingData,
            ),
          );
        }
        print('RoutesManager: Invalid arguments for ownerTripRequestScreen');
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Error: Invalid arguments for owner trip request screen'),
            ),
          ),
        );
      case ScreensName.renterOngoingTripScreen:
        if (routeSettings.arguments is AppNotification) {
          final notification = routeSettings.arguments as AppNotification;
          return MaterialPageRoute(
            builder: (context) => RenterOngoingTripScreen(
              notification: notification,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Error: Invalid arguments for renter ongoing trip screen'),
            ),
          ),
        );
      case ScreensName.ownerOngoingTripScreen:
        if (routeSettings.arguments is AppNotification) {
          final notification = routeSettings.arguments as AppNotification;
          return MaterialPageRoute(
            builder: (context) => OwnerOngoingTripScreen(
              notification: notification,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
                child: Text(
                    'Error: Missing required arguments for owner ongoing trip')),
          ),
        );
      case ScreensName.liveLocationMapScreen:
        if (routeSettings.arguments is Map<String, dynamic>) {
          final args = routeSettings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => LiveLocationMapScreen(
              tripId: args['tripId'] as String,
              carId: args['carId'] as String,
              renterId: args['renterId'] as String,
              rentalId: args['rentalId'] as String,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
                child: Text(
                    'Error: Missing required arguments for live location map')),
          ),
        );
      case '/cancel-rental':
        return MaterialPageRoute(
          builder: (context) => const CancelRentalScreen(),
        );
      case ScreensName.sentRequestToOwnerScreen:
        return MaterialPageRoute(
          builder: (context) => const SentRequestToOwnerScreen(),
        );
      case ScreensName.savedTripsScreen:
        return MaterialPageRoute(builder: (_) => const SavedTripsScreen());
      case ScreensName.tripDetailsReadOnlyScreen:
        final trip = routeSettings.arguments as TripDetailsModel;
        return MaterialPageRoute(builder: (_) => TripDetailsReadOnlyScreen(trip: trip));

      // Test screens
      case ScreensName.testLoginScreen:
        return MaterialPageRoute(builder: (_) => const TestLoginScreen());
      
      case ScreensName.testBookingApiScreen:
        return MaterialPageRoute(builder: (_) => const TestBookingApiScreen());

      case ScreensName.newnotifytest:
        return MaterialPageRoute(builder: (_) => NewNotificationsScreen());
      
      // case ScreensName.rentalFlowTestScreen:
      //   return MaterialPageRoute(builder: (_) => const flow_test.RentalFlowTestScreen());

      default:
        return MaterialPageRoute(builder: (context) {
          return const Scaffold(
            body: Center(
              child: Text('Error , failed to navigate'),
            ),
          );
        });
    }
  }
}
