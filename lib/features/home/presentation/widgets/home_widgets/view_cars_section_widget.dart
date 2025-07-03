import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../cars/presentation/cubits/add_car_cubit.dart';
import '../../cubit/car_cubit.dart';
import '../../cubit/choose_car_state.dart';
import '../../model/car_model.dart';
import '../../screens/booking_screens/car_details_screen.dart';
import 'car_card_widget.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import 'package:test_cark/features/cars/presentation/cubits/add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';

class ViewCarsSectionWidget extends StatefulWidget {
  const ViewCarsSectionWidget({super.key});

  @override
  State<ViewCarsSectionWidget> createState() => _ViewCarsSectionWidgetState();
}

class _ViewCarsSectionWidgetState extends State<ViewCarsSectionWidget> {
  List<CarBundle> _availableCars = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableCars();
  }

  Future<void> _loadAvailableCars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final addCarCubit = context.read<AddCarCubit>();
      final cars = await addCarCubit.fetchAllAvailableCars();
      setState(() {
        _availableCars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, ChooseCarState>(
      builder: (context, state) {
        final rentalState = context.watch<CarCubit>().state;
        final showWithDriver = rentalState.withDriver;
        final showWithoutDriver = rentalState.withoutDriver;
        
        // Get current user to filter cars
        final authCubit = context.read<AuthCubit>();
        final currentUser = authCubit.userModel;

        if (_isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 8.h),
                Text(
                  'Error loading cars',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: _loadAvailableCars,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          );
        }

        final filteredCars = _availableCars.where((bundle) {
          final car = bundle.car;
          final rentalOptions = bundle.rentalOptions;
          final matchesType =
              state.carType == null || car.carType == state.carType;

          final matchesCategory =
              state.category == null || car.carCategory == state.category;

          final matchesTransmission = state.transmission == null ||
              car.transmissionType == state.transmission;

          final matchesFuel = state.fuel == null || car.fuelType == state.fuel;

          // Driver filter logic:
          final matchesDriver = (showWithDriver == true &&
                  rentalOptions?.availableWithDriver == true) ||
              (showWithoutDriver == true &&
                  rentalOptions?.availableWithoutDriver == true) ||
              (showWithDriver == null && showWithoutDriver == null);

          // For home screen: show cars that don't belong to current user
          // For owner home screen: show only current user's cars
          final matchesOwnership = currentUser?.role == 'owner' 
              ? car.ownerId == currentUser?.id  // Owner sees only their cars
              : car.ownerId != currentUser?.id; // Renter sees cars from other owners

          return matchesType &&
              matchesCategory &&
              matchesTransmission &&
              matchesFuel &&
              matchesDriver &&
              matchesOwnership;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - Changed to "Available Cars"
            Text(
              currentUser?.role == 'owner' ? 'My Cars' : 'Available Cars',
              style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.02.sh),

            // Debug information (can be removed in production)
            if (showWithDriver != null || showWithoutDriver != null)
              Padding(
                padding: EdgeInsets.only(bottom: 0.01.sh),
                child: Text(
                  "Driver Filter: ${showWithDriver == true ? 'With Driver' : showWithoutDriver == true ? 'Without Driver' : 'None'}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),

            // Cars list
            if (filteredCars.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      currentUser?.role == 'owner' 
                          ? "You haven't added any cars yet."
                          : "No cars available at the moment.",
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      currentUser?.role == 'owner'
                          ? "Add your first car to start renting!"
                          : "Check back later for new cars.",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: _loadAvailableCars,
                child: ListView.builder(
                  itemCount: filteredCars.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: CarCardWidget(
                        car: filteredCars[index].car,
                        rentalOptions: filteredCars[index].rentalOptions,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarDetailsScreen(carBundle: filteredCars[index]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
