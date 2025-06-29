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

class ViewCarsSectionWidget extends StatelessWidget {
  ViewCarsSectionWidget({super.key});

  // Enhanced dummy data for cars with driver information
  final List<CarModel> dummyCars = [
    CarModel(
      id: 1,
      model: 'Camry',
      brand: 'Toyota',
      carType: 'Sedan',
      carCategory: 'Economy',
      plateNumber: 'ABC123',
      year: 2022,
      color: 'White',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Petrol',
      currentOdometerReading: 35000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      rentalOptions: RentalOptions(
        availableWithoutDriver: true,
        availableWithDriver: true,
        dailyRentalPrice: 120.0,
        dailyRentalPriceWithDriver: 180.0,
      ),
      imageUrl:
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
      driverName: 'Ahmed Hassan',
      driverRating: 4.8,
      driverTrips: 156,
      kmLimitPerDay: 200,
      waitingHourCost: 15.0,
      extraKmRate: 0.5,
      ownerId: 'owner1',
    ),
    CarModel(
      id: 2,
      model: 'Accord',
      brand: 'Honda',
      carType: 'Sedan',
      carCategory: 'Economy',
      plateNumber: 'XYZ789',
      year: 2023,
      color: 'Black',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Petrol',
      currentOdometerReading: 12000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      rentalOptions: RentalOptions(
        availableWithoutDriver: true,
        availableWithDriver: true,
        dailyRentalPrice: 140.0,
        dailyRentalPriceWithDriver: 200.0,
      ),
      imageUrl:
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400',
      driverName: 'Mohammed Ali',
      driverRating: 4.9,
      driverTrips: 203,
      kmLimitPerDay: 250,
      waitingHourCost: 18.0,
      extraKmRate: 0.6,
      ownerId: 'owner2',
    ),
    CarModel(
      id: 3,
      model: '3 Series',
      brand: 'BMW',
      carType: 'Sedan',
      carCategory: 'Luxury',
      plateNumber: 'BMW001',
      year: 2022,
      color: 'Blue',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Petrol',
      currentOdometerReading: 5000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      rentalOptions: RentalOptions(
        availableWithoutDriver: true,
        availableWithDriver: true,
        dailyRentalPrice: 180.0,
        dailyRentalPriceWithDriver: 250.0,
      ),
      imageUrl:
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400',
      driverName: 'Omar Khalil',
      driverRating: 4.7,
      driverTrips: 89,
      kmLimitPerDay: 300,
      waitingHourCost: 20.0,
      extraKmRate: 0.7,
      ownerId: 'owner3',
    ),
    CarModel(
      id: 4,
      model: 'C-Class',
      brand: 'Mercedes',
      carType: 'Sedan',
      carCategory: 'Luxury',
      plateNumber: 'MB001',
      year: 2023,
      color: 'Silver',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Petrol',
      currentOdometerReading: 8000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      rentalOptions: RentalOptions(
        availableWithoutDriver: true,
        availableWithDriver: true,
        dailyRentalPrice: 220.0,
        dailyRentalPriceWithDriver: 300.0,
      ),
      imageUrl:
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400',
      driverName: 'Youssef Mahmoud',
      driverRating: 4.9,
      driverTrips: 134,
      kmLimitPerDay: 350,
      waitingHourCost: 25.0,
      extraKmRate: 0.8,
      ownerId: 'owner4',
    ),
  ];

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
        
        // Get cars from AddCarCubit and combine with dummy cars
        final addCarCubit = context.read<AddCarCubit>();
        final allCars = [...dummyCars, ...addCarCubit.getCars()];

        final filteredCars = allCars.where((car) {
          final matchesType =
              state.carType == null || car.carType == state.carType;

          final matchesCategory =
              state.category == null || car.carCategory == state.category;

          final matchesTransmission = state.transmission == null ||
              car.transmissionType == state.transmission;

          final matchesFuel = state.fuel == null || car.fuelType == state.fuel;

          // Driver filter logic:
          // - If withDriver is true: show only cars available with driver
          // - If withoutDriver is true: show only cars available without driver
          // - If both are null: show all cars (no driver filter applied)
          final matchesDriver = (showWithDriver == true &&
                  car.rentalOptions.availableWithDriver == true) ||
              (showWithoutDriver == true &&
                  car.rentalOptions.availableWithoutDriver == true) ||
              (showWithDriver == null && showWithoutDriver == null);

          // Ownership filter: 
          // - If user is owner: show only their own cars
          // - If user is renter: don't show their own cars
          final matchesOwnership = currentUser?.role == 'owner' 
              ? car.ownerId == currentUser?.id  // Owner sees only their cars
              : car.ownerId != currentUser?.id; // Renter sees cars they don't own

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
              Text(
                "No cars match your filters.",
                style: TextStyle(fontSize: 16.sp),
              )
            else
              ListView.builder(
                itemCount: filteredCars.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: CarCardWidget(
                      car: filteredCars[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CarDetailsScreen(car: filteredCars[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
