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

  // ✅ تعديل الدالة لجلب العربيات الحقيقية من الـ backend
  // Future<void> fetchCarsFromServer() async {
  //   emit(AddCarLoading());
  //   try {
  //     _cars = await _carService.fetchUserCars(); // ✅ هنا تم الاستبدال
  //     emit(AddCarInitial());
  //   } catch (e) {
  //     emit(AddCarError(message: _handleError(e)));
  //   }
  // }
  Future<void> fetchCarsFromServer() async {
    emit(AddCarLoading());
    try {
      final carService = CarService();
      final cars = await carService.fetchUserCars();

      // Replace current list with fetched cars
      _cars.clear();
      _cars.addAll(cars);

      emit(AddCarFetchedSuccessfully(cars: cars));
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }
  // Future<void> fetchCarsFromServer() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('access_token');
  //   final userId = prefs.getString('user_id');
  //
  //   final response = await ApiService().getWithToken('cars/', token!);
  //   final List<dynamic> data = response.data;
  //
  //   final cars = data
  //       .map((json) => CarModel.fromJson(json))
  //       .where((car) => car.ownerId == userId)
  //       .toList();
  //
  //   setState(() {
  //     _cars = cars;
  //   });
  // }


  /// Adds a new car
  Future<void> addCar(CarModel car) async {
    emit(AddCarLoading());
    try {
      final response = await ApiService().postWithToken('cars/', {
        "model": car.model,
        "brand": car.brand,
        "car_type": car.carType,
        "car_category": car.carCategory,
        "plate_number": car.plateNumber,
        "year": car.year,
        "color": car.color,
        "seating_capacity": car.seatingCapacity,
        "transmission_type": car.transmissionType,
        "fuel_type": car.fuelType,
        "current_odometer_reading": car.currentOdometerReading,
      });

    final responseData = response.data;
    print("RESPONSE DATA: $responseData");
    final newCar = CarModel.fromJson(responseData);

    final authCubit = BlocProvider.of<AuthCubit>(navigatorKey.currentContext!);
    await authCubit.loadUserData();
    final userId = authCubit.userModel!.id;

      // Simulate an API call or database operation
      // await Future.delayed(const Duration(seconds: 1));

      // Add car to list
      _cars.add(newCar);

      // Uncomment and use repository when implemented
      // await carRepository.addCar(car);

      emit(AddCarSuccess(car: car));

      if(userId == 1) {
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
      // Simulate an API call or database operation
      await Future.delayed(const Duration(seconds: 1));

      // Find and update car
      final index =
          _cars.indexWhere((car) => car.plateNumber == updatedCar.plateNumber);
      if (index != -1) {
        _cars[index] = updatedCar;
        emit(AddCarSuccess(car: updatedCar));
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
      // Simulate an API call or database operation
      await Future.delayed(const Duration(seconds: 1));

      // Remove car from list
      final success = _cars.remove(car);
      if (success) {
        emit(AddCarSuccess(car: car));
      } else {
        emit(AddCarError(message: 'Car not found'));
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
