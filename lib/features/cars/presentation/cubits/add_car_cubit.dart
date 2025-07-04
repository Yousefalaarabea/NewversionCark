import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/home/presentation/cubit/car_cubit.dart';
import '../../../../core/api_service.dart';
import '../../../../core/car_service.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import 'add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AddCarCubit extends Cubit<AddCarState> {
  final CarService _carService = CarService();
  List<CarBundle> _cars = [];

  AddCarCubit() : super(AddCarInitial());

  List<CarBundle> getCars() => _cars;

  // Fetch all available cars for home screen
  Future<List<CarBundle>> fetchAllAvailableCars() async {
    try {
      print('🔄 AddCarCubit: Fetching all available cars...');
      final carBundlesRaw = await _carService.fetchAllCars();
      print('✅ AddCarCubit: Raw data received: ${carBundlesRaw.length} cars');
      
      final carBundles = carBundlesRaw.map((e) {
        final car = e['car'] as CarModel;
        final rentalOptions = e['rentalOptions'] as CarRentalOptions?;
        final usagePolicy = e['usagePolicy'] as CarUsagePolicy?;
        
        print('   📦 Creating CarBundle for: ${car.brand} ${car.model}');
        print('      - RentalOptions: ${rentalOptions != null ? "Available" : "Null"}');
        print('      - UsagePolicy: ${usagePolicy != null ? "Available" : "Null"}');
        
        return CarBundle(
          car: car,
          rentalOptions: rentalOptions,
          usagePolicy: usagePolicy,
        );
      }).toList();
      
      print('✅ AddCarCubit: Created ${carBundles.length} CarBundles');
      return carBundles;
    } catch (e) {
      print('❌ AddCarCubit: Error fetching all available cars: $e');
      return [];
    }
  }

  Future<void> fetchCarsFromServer() async {
    emit(AddCarLoading());
    try {
      final carBundlesRaw = await _carService.fetchUserCars();
      final carBundles = carBundlesRaw.map((e) => CarBundle(
        car: e['car'],
        rentalOptions: e['rentalOptions'],
        usagePolicy: e['usagePolicy'],
      )).toList();
      _cars = carBundles;
      emit(AddCarFetchedSuccessfully(cars: carBundles));
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<void> addCar({
    required CarModel car,
    required CarRentalOptions rentalOptions,
    required CarUsagePolicy usagePolicy,
  }) async {
    emit(AddCarLoading());
    try {
      final success = await _carService.addCar(
        carData: car.toJson(),
        rentalOptionsData: rentalOptions.toJson(),
        usagePolicyData: usagePolicy.toJson(),
      );
      if (success) {
        await fetchCarsFromServer();
        if (_cars.isNotEmpty) {
          emit(AddCarSuccess(carBundle: _cars.last));
        }
      } else {
        emit(const AddCarError(message: 'Failed to add car'));
      }
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<void> updateCar({
    required String carId,
    required CarModel car,
    required CarRentalOptions rentalOptions,
    required CarUsagePolicy usagePolicy,
  }) async {
    emit(AddCarLoading());
    try {
      final success = await _carService.updateCar(
        carId: carId,
        carData: car.toJson(),
        rentalOptionsData: rentalOptions.toJson(),
        usagePolicyData: usagePolicy.toJson(),
      );
      if (success) {
        await fetchCarsFromServer();
        final updated = _cars.firstWhere((b) => b.car.id.toString() == carId, orElse: () => CarBundle(car: car));
        emit(AddCarSuccess(carBundle: updated));
      } else {
        emit(const AddCarError(message: 'Failed to update car'));
      }
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<void> deleteCar(String carId) async {
    emit(AddCarLoading());
    try {
      final success = await _carService.deleteCar(carId);
      if (success) {
        _cars.removeWhere((b) => b.car.id.toString() == carId);
        emit(AddCarFetchedSuccessfully(cars: _cars));
      } else {
        emit(const AddCarError(message: 'Failed to delete car'));
      }
    } catch (e) {
      emit(AddCarError(message: e.toString()));
    }
  }

  Future<CarBundle?> fetchCarById(String carId) async {
    try {
      final data = await _carService.getCarDetails(carId);
      if (data != null) {
        final bundle = CarBundle(
          car: data['car'],
          rentalOptions: data['rentalOptions'],
          usagePolicy: data['usagePolicy'],
        );
        return bundle;
      }
      return null;
    } catch (e) {
      emit(AddCarError(message: e.toString()));
      return null;
    }
  }

  void reset() {
    emit(AddCarInitial());
  }

  void refreshCars() {
    emit(AddCarInitial());
  }
}