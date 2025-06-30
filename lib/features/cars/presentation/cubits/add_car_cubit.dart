import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/home/presentation/cubit/car_cubit.dart';
import '../../../../core/api_service.dart';
import '../../../../core/car_service.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import 'add_car_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AddCarCubit extends Cubit<AddCarState> {
  // In-memory storage for cars (replace with actual database in production)
  // final List<CarModel> _cars = [
  //   // Sample test data
  //   CarModel(
  //     id: 1,
  //     model: 'Model S',
  //     brand: 'Tesla',
  //     carType: 'Sedan',
  //     carCategory: 'Luxury',
  //     plateNumber: 'ABC123',
  //     year: 2020,
  //     color: 'Red',
  //     seatingCapacity: 5,
  //     transmissionType: 'Automatic',
  //     fuelType: 'Electric',
  //     currentOdometerReading: 15000,
  //     availability: true,
  //     currentStatus: 'Available',
  //     approvalStatus: true,
  //     rentalOptions: RentalOptions(
  //       availableWithoutDriver: true,
  //       availableWithDriver: false,
  //       dailyRentalPrice: 500.0,
  //
  //     ), ownerId: '1',
  //   ),
  //
  //   CarModel(
  //     id: 2,
  //     model: 'Civic',
  //     brand: 'Honda',
  //     carType: 'Sedan',
  //     carCategory: 'Standard',
  //     plateNumber: 'XYZ789',
  //     year: 2019,
  //     color: 'Blue',
  //     seatingCapacity: 5,
  //     transmissionType: 'Manual',
  //     fuelType: 'Gasoline',
  //     currentOdometerReading: 30000,
  //     availability: true,
  //     currentStatus: 'Available',
  //     approvalStatus: true,
  //     rentalOptions: RentalOptions(
  //       availableWithoutDriver: true,
  //       availableWithDriver: true,
  //       dailyRentalPrice: 300.0,
  //     ), ownerId: '2',
  //   ),
  // ];

  final CarService _carService = CarService();
  List<CarModel> _cars = [];

  // Constructor with optional dependency injection
  AddCarCubit() : super(AddCarInitial());

  // Get all cars
  List<CarModel> getCars() => _cars;

  // Fetch all cars from server
  Future<void> fetchAllCars() async {
    emit(AddCarLoading());
    try {
      final cars = await _carService.fetchAllCars();
      _cars.clear();
      _cars.addAll(cars);
      emit(AddCarFetchedSuccessfully(cars: cars));
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  // Fetch user's cars from server
  Future<void> fetchCarsFromServer() async {
    emit(AddCarLoading());
    try {
      final cars = await _carService.fetchUserCars();
      _cars.clear();
      _cars.addAll(cars);
      emit(AddCarFetchedSuccessfully(cars: cars));
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  // Fetch specific car by ID
  Future<CarModel?> fetchCarById(int carId) async {
    try {
      final car = await _carService.fetchCarById(carId);
      return car;
    } catch (e) {
      emit(AddCarError(message: e.toString()));
      return null;
    }
  }

  /// Adds a new car
  Future<void> addCar(CarModel car) async {
    emit(AddCarLoading());
    try {
      // Create car using the API
      final newCar = await _carService.createCar(car);
      
      // Add car to local list
      _cars.add(newCar);

      emit(AddCarSuccess(car: newCar));

      // Update user role if needed
      final authCubit = BlocProvider.of<AuthCubit>(navigatorKey.currentContext!);
      final userId = authCubit.userModel!.id;

      if (userId == 1) {
        try {
          final roleResponse = await ApiService().postWithToken(
            'users/user-role/',
            {
              "user": userId,
              "role": 2, // Owner
            },
          );
          print('Role updated: ${roleResponse.data}');
        } catch (e) {
          print('Failed to update role: $e');
        }
      }
    } catch (e) {
      emit(AddCarError(message: _handleError(e)));
    }
  }

  /// Updates an existing car
  Future<void> updateCar(CarModel updatedCar) async {
    emit(AddCarLoading());

    try {
      // Update car using the API
      final updatedCarFromApi = await _carService.updateCar(updatedCar.id, updatedCar);
      
      // Update car in local list
      final index = _cars.indexWhere((car) => car.id == updatedCar.id);
      if (index != -1) {
        _cars[index] = updatedCarFromApi;
        emit(AddCarSuccess(car: updatedCarFromApi));
      } else {
        emit(const AddCarError(message: 'Car not found'));
      }
    } catch (e) {
      emit(AddCarError(message: _handleError(e)));
    }
  }

  /// Deletes a car
  Future<void> deleteCar(CarModel car) async {
    emit(AddCarLoading());

    try {
      // Delete car using the API
      final success = await _carService.deleteCar(car.id);
      
      if (success) {
        // Remove car from local list
        _cars.removeWhere((c) => c.id == car.id);
        emit(AddCarSuccess(car: car));
      } else {
        emit(const AddCarError(message: 'Failed to delete car'));
      }
    } catch (e) {
      emit(AddCarError(message: _handleError(e)));
    }
  }

  /// Resets the form state to initial
  void reset() {
    emit(AddCarInitial());
  }

  /// Refreshes the cars list and emits a state change for UI updates
  void refreshCars() {
    emit(AddCarInitial());
  }

  /// Error handling helper
  String _handleError(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return 'An unexpected error occurred';
    }
  }
}
