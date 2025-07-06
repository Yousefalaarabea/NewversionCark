import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/core/utils/assets_manager.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../auth/presentation/screens/profile/profile_screen.dart';
import '../../widgets/home_widgets/brand_section_widget.dart';
import '../../widgets/home_widgets/view_cars_section_widget.dart';
import '../../widgets/home_widgets/notification_badge_widget.dart';
import '../../widgets/rental_widgets/filter_button.dart';
import '../../widgets/rental_widgets/rental_summary_card.dart';
import '../booking_screens/booking_history_screen.dart';
import '../booking_screens/payment_methods_screen.dart';
import '../booking_screens/payment_screen.dart';
import '../booking_screens/rental_search_screen.dart';
import 'contact_help_screen.dart';
import 'feedback_screen.dart';
import 'notification_test_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateAndCloseDrawer(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _logout(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    // Use the new logout method from AuthCubit
    authCubit.logout();
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacementNamed(context, ScreensName.login);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  void initState() {
    Timer? _timer;
    _timer = Timer.periodic(const Duration(minutes:5), (timer) => print("#####New Refresh####"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) =>
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
          actions: [
            // Notification icon with badge
            NotificationBadgeWidget(
              onTap: () {
                // Navigate to appropriate notification screen based on user role
                final authCubit = context.read<AuthCubit>();
                final user = authCubit.userModel;
                // if (user?.role == 'owner') {
                //   Navigator.pushNamed(
                //       context, ScreensName.newnotifytest);
                // } else {
                //   Navigator.pushNamed(
                //       context, ScreensName.newnotifytest);
                // }
                Navigator.pushNamed(
                    context, ScreensName.newnotifytest);
              },
            ),
          ],
        ),
        drawer: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            final user = authCubit.userModel;
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage(AssetsManager.carLogo),
                          width: 0.15.sw,
                        ),
                        SizedBox(height: 0.01.sh),
                        if (user != null)
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (user != null)
                          Text(
                            user.role == 'owner' ? 'Car Owner' : 'Renter',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () =>
                        _navigateAndCloseDrawer(context, const ProfileScreen()),
                  ),
                  const Divider(),
                  // Switch to Owner
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text('Switch to Owner'),
                    onTap: () async {
                      final authCubit = context.read<AuthCubit>();
                      await authCubit.switchToOwner();
                      Navigator.pop(context); // Close drawer

                      // Navigate to OwnerHomeScreen
                      Navigator.pushReplacementNamed(
                          context, ScreensName.ownerHomeScreen);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Switched to Owner mode')),
                      );
                    },
                  ),
                  // Switch to Renter (only show if user is owner)
                  if (user?.role == 'owner')
                    ListTile(
                      leading: const Icon(Icons.switch_account),
                      title: const Text('Switch to Renter'),
                      onTap: () async {
                        final authCubit = context.read<AuthCubit>();
                        await authCubit.switchToRenter();
                        Navigator.pop(context); // Close drawer
                        Navigator.pushReplacementNamed(
                            context, ScreensName.homeScreen);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              'Switched to Renter mode')),
                        );
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Booking History'),
                    onTap: () =>
                        _navigateAndCloseDrawer(
                            context, const BookingHistoryScreen()),
                  ),
                  // Booking Requests (only for renters)
                  if (user?.role == 'renter')
                    ListTile(
                      leading: const Icon(Icons.pending_actions),
                      title: const Text('Booking Requests'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.pushNamed(
                            context, ScreensName.bookingRequestScreen);
                      },
                    ),
                  // ListTile(
                  //   leading: const Icon(Icons.credit_card),
                  //   title: const Text('Payment Methods'),
                  //   onTap: () => _navigateAndCloseDrawer(
                  //       context, PaymentMethodsScreen(car: , totalPrice: /* provide totalPrice */)),
                  // ),
                  ListTile(
                    leading: const Icon(Icons.contact_support),
                    title: const Text('Contact & Help'),
                    onTap: () =>
                        _navigateAndCloseDrawer(context, const ContactHelpScreen()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Feedback'),
                    onTap: () =>
                        _navigateAndCloseDrawer(context, const FeedbackScreen()),
                  ),
                  // Test Notifications (for development)
                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Test Notifications'),
                    onTap: () =>
                        _navigateAndCloseDrawer(
                            context, const NotificationTestScreen()),
                  ),
                  // Test Login API (for development)
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Test Login API'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, '/test-login');
                    },
                  ),
                  // Test Booking API (for development)
                  ListTile(
                    leading: const Icon(Icons.book_online),
                    title: const Text('Test Booking API'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, '/test-booking-api');
                    },
                  ),
                  // Test Rental Flow (for development)
                  ListTile(
                    leading: const Icon(Icons.route),
                    title: const Text('Test Rental Flow'),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, '/rental-flow-test');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            );
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(0.03.sw),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 0.02.sh),

                  // Search Bar
                  // const CustomSearchBar(),
                  const RentalSummaryCard(),
                  SizedBox(height: 0.02.sh),

                  // Filter Button
                  const FilterButton(),
                  SizedBox(height: 0.02.sh),

                  // All brands in general
                  const BrandSectionWidget(),

                  // View Cars Section
                  ViewCarsSectionWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// removed from ui:
//Column(
//                       children: [
//                         Text("Location",
//                             style: TextStyle(
//                                 fontSize: 0.04.sw,
//                                 fontWeight: FontWeight.w500)),
//                         const Row(
//                           children: [
//                             Icon(Icons.location_on, color: Colors.red),
//                             Text("Alex, Egypt") //
//                           ],
//                         )
//                       ],
//                     ),
/// car section
// const Cars(
//     title: 'Top Rated Cars',
//     imagePath: 'assets/images/home/car1(home).png'),
// const Cars(
//     title: 'Most Popular Cars',
//     imagePath: 'assets/images/home/car1(home).png'),
/// Rent a Car anytime text
// Text(TextManager.rentCarText.tr(),
//     style: TextStyle(
//         fontSize: 0.02.sh, fontWeight: FontWeight.bold),),
// SizedBox(height: 0.02.sh),
