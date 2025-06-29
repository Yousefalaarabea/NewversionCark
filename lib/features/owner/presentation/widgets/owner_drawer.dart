import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/profile/profile_screen.dart';
import '../../../cars/presentation/screens/add_car_screen.dart';
import '../../../../config/routes/screens_name.dart';
import '../../../../core/utils/assets_manager.dart';

class OwnerDrawer extends StatelessWidget {
  const OwnerDrawer({super.key});

  void _navigateAndCloseDrawer(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _switchToRenter(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    // Use the new switchToRenter method
    authCubit.switchToRenter();
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacementNamed(context, ScreensName.homeScreen);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switched to Renter mode')),
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
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final user = authCubit.userModel;
        
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
                        'Car Owner',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              // Home (Owner Cars List)
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home (Owner Cars List)'),
                onTap: () => Navigator.pop(context), // Already on home
              ),
              // Profile
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => _navigateAndCloseDrawer(context, const ProfileScreen()),
              ),
              // Add Car
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Add Car'),
                onTap: () => _navigateAndCloseDrawer(context, const AddCarScreen()),
              ),
              const Divider(),
              // Switch to Renter
              ListTile(
                leading: const Icon(Icons.switch_account),
                title: const Text('Switch to Renter'),
                onTap: () => _switchToRenter(context),
              ),
              const Divider(),
              // Logout
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
} 