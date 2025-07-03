import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../config/routes/screens_name.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:test_cark/features/auth/presentation/screens/profile/profile_screen.dart';
import 'add_car_screen.dart';
import '../widgets/car_data_table.dart';
import 'view_car_details_screen.dart';

class ViewCarsScreen extends StatefulWidget {
  // const ViewCarsScreen({super.key});
  final int? userRole; // 🟡

  const ViewCarsScreen({super.key, this.userRole});
  @override
  State<ViewCarsScreen> createState() => _ViewCarsScreenState();
}

class _ViewCarsScreenState extends State<ViewCarsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddCarCubit>().fetchCarsFromServer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, CarModel car) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
              SizedBox(width: 10.w),
              Text(
                'Delete Car',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you want to delete this car?',
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                '${car.brand} ${car.model}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Plate Number: ${car.plateNumber}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AddCarCubit>().deleteCar(car.id.toString());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateAndCloseDrawer(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _logout(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    // Clear user session
    authCubit.userModel = null;
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacementNamed(context, ScreensName.login);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.userModel;

    // Get the cars and filter by current user's ID
    // final allCars = context.read<AddCarCubit>().getCars();
    // final cars =
    //     allCars.where((car) => car.ownerId == currentUser?.id).toList();

    final carBundles = context.watch<AddCarCubit>().getCars();
    final filteredCarBundles = carBundles.where((bundle) => bundle.car.ownerId == currentUser?.id).toList();

    return Scaffold(
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
                        const Text(
                          'Car Owner',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                // Home (My Cars)
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('My Cars'),
                  onTap: () => Navigator.pop(context), // Already on home
                ),
                // Profile
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () =>
                      _navigateAndCloseDrawer(context, const ProfileScreen()),
                ),
                // Add Car
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Add Car'),
                  onTap: () =>
                      _navigateAndCloseDrawer(context, const AddCarScreen()),
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
      ),

      body: BlocConsumer<AddCarCubit, AddCarState>(
        listener: (context, state) {
          if (state is AddCarSuccess) {
            // Refresh the cars list after successful operation
            context.read<AddCarCubit>().fetchCarsFromServer();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Car updated successfully!'
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is AddCarError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddCarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddCarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading cars',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AddCarCubit>().fetchCarsFromServer();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AddCarFetchedSuccessfully) {
            final carBundles = state.cars;
            final filteredCarBundles = carBundles.where((bundle) => bundle.car.ownerId == currentUser?.id).toList();

            if (filteredCarBundles.isEmpty) {
              // No cars found, show empty state
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No cars found. Add your first car!',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, ScreensName.addCarScreen);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Add Car',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(16.w),
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<AddCarCubit>().fetchCarsFromServer();
                },
                child: CarDataTable(
                  cars: filteredCarBundles,
                  onEdit: (CarBundle bundle) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCarScreen(carToEdit: bundle.car),
                      ),
                    ).then((_) {
                      context.read<AddCarCubit>().fetchCarsFromServer();
                    });
                  },
                  onDelete: (CarBundle bundle) => _showDeleteConfirmation(context, bundle.car),
                  onViewDetails: (CarBundle bundle) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewCarDetailsScreen(carBundle: bundle),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          // Default loading state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
