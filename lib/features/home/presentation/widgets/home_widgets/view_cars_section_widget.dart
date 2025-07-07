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
      print('🔄 Loading available cars...');
      final addCarCubit = context.read<AddCarCubit>();
      final cars = await addCarCubit.fetchAllAvailableCars();
      print('✅ Loaded ${cars.length} cars from API');
      
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i].car;
        print(car);
        print('   ${i + 1}. ${car.brand} ${car.model} (Owner: ${car.ownerId}) (img: ${car.imageUrl}');
      }
      
      setState(() {
        _availableCars = cars;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading cars: $e');
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

        // Debug logging for filter state
        print('🔍 Filter State:');
        print('   - Car Type: ${state.carType}');
        print('   - Category: ${state.category}');
        print('   - Transmission: ${state.transmission}');
        print('   - Fuel: ${state.fuel}');
        print('   - Show With Driver: $showWithDriver');
        print('   - Show Without Driver: $showWithoutDriver');
        print('   - User Role: ${currentUser?.role}');
        print('   - User ID: ${currentUser?.id}');
        
        // For testing: show all cars without filtering
        // Uncomment the next line to show all cars without any filtering
        // final filteredCars = _availableCars;
        
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

          // Driver filter logic - simplified to handle null rentalOptions
          bool matchesDriver = true; // Default to true
          if (showWithDriver == true || showWithoutDriver == true) {
            // Only apply driver filter if user explicitly selected it
            if (rentalOptions != null) {
              matchesDriver = (showWithDriver == true &&
                      rentalOptions.availableWithDriver == true) ||
                  (showWithoutDriver == true &&
                      rentalOptions.availableWithoutDriver == true);
            } else {
              // If rentalOptions is null, assume car is available for both options
              matchesDriver = true;
            }
          }

          // For home screen: show all available cars to renters
          // For owner home screen: show only current user's cars
          final matchesOwnership = currentUser?.role == 'owner' 
              ? car.ownerId == currentUser?.id  // Owner sees only their cars
              : true; // Renter sees all available cars

          final shouldInclude = matchesType &&
              matchesCategory &&
              matchesTransmission &&
              matchesFuel &&
              matchesDriver &&
              matchesOwnership;

          // Debug logging
          print('🔍 Filtering car: ${car.brand} ${car.model}');
          print('   - Type match: $matchesType (${state.carType} vs ${car.carType})');
          print('   - Category match: $matchesCategory (${state.category} vs ${car.carCategory})');
          print('   - Transmission match: $matchesTransmission (${state.transmission} vs ${car.transmissionType})');
          print('   - Fuel match: $matchesFuel (${state.fuel} vs ${car.fuelType})');
          print('   - Driver match: $matchesDriver (rentalOptions: ${rentalOptions != null ? "Available" : "Null"})');
          print('   - Ownership match: $matchesOwnership (User role: ${currentUser?.role}, User ID: ${currentUser?.id}, Car owner: ${car.ownerId})');
          print('   - Final result: $shouldInclude');

          return shouldInclude;
        }).toList();

        print('🎯 Total cars after filtering: ${filteredCars.length}');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - Changed to "Available Cars"
            Text(
              currentUser?.role == 'owner' ? 'My Cars' : 'Available Cars',
              style: TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 0.02.sh),
            if (showWithDriver != null || showWithoutDriver != null)
              Padding(
                padding: EdgeInsets.only(bottom: 0.01.sh),
                child: Text(
                  "Driver Filter: ${showWithDriver == true ? 'With Driver' : showWithoutDriver == true ? 'Without Driver' : 'None'}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            if (filteredCars.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      currentUser?.role == 'owner' 
                          ? "You haven't added any cars yet."
                          : "No cars available at the moment.",
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      currentUser?.role == 'owner'
                          ? "Add your first car to start renting!"
                          : "Check back later for new cars.",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    if (currentUser?.role == 'owner')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/addCarScreen');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Car'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
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
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemBuilder: (context, index) {
                    return CarCardWidget(
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
