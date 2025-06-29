// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:test_cark/features/auth/presentation/screens/profile/profile_screen.dart';
// import 'package:test_cark/features/home/presentation/screens/home_screens/home_screen.dart';
// import 'package:test_cark/features/notifications/presentation/screens/renter_notification_screen.dart';
// import '../../../auth/presentation/widgets/shared/bottom_navigation_bar_widget.dart';
// import '../../cubit/navigation_cubit.dart';
// import '../../cubit/navigation_state.dart';
//
// class MainNavigationScreen extends StatelessWidget {
//   MainNavigationScreen({super.key});
//
//   final List<Widget> _screens = [
//     HomeScreen(),
//     const RenterNotificationScreen(),
//     const ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NavigationCubit, NavigationState>(
//       builder: (context, state) {
//         final cubit = context.read<NavigationCubit>();
//         return Scaffold(
//           body: _screens[cubit.selectedIndex],
//           bottomNavigationBar: BottomNavigationBarWidget(
//             selectedIndex: cubit.selectedIndex,
//             onTap: cubit.updateSelectedIndex,
//           ),
//         );
//       },
//     );
//   }
// }
