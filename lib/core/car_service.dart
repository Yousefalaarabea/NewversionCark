// ✅ Complete Car Service with all CRUD operations

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';

import 'api_service.dart';

class CarService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://cark-f3fjembga0f6btek.uaenorth-01.azurewebsites.net/api/', // 🔁 url السيرفر بتاعنا من الباك
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // GET all cars
  Future<List<CarModel>> fetchAllCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService().getWithToken('cars/', token);
      final List<dynamic> data = response.data;
      
      return data.map((json) => CarModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching all cars: $e');
      rethrow;
    }
  }

  // GET user's cars only
  Future<List<CarModel>> fetchUserCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService().getWithToken('cars/', token);
      final List<dynamic> data = response.data;
      
      return data
          .map((json) => CarModel.fromJson(json))
          .where((car) => car.ownerId == userId)
          .toList();
    } catch (e) {
      print('Error fetching user cars: $e');
      rethrow;
    }
  }

  // GET specific car by ID
  Future<CarModel> fetchCarById(int carId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService().getWithToken('cars/$carId/', token);
      return CarModel.fromJson(response.data);
    } catch (e) {
      print('Error fetching car by ID: $e');
      rethrow;
    }
  }

  // POST new car
  Future<CarModel> createCar(CarModel car) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService().postWithToken('cars/', car.toJson());
      return CarModel.fromJson(response.data);
    } catch (e) {
      print('Error creating car: $e');
      rethrow;
    }
  }

  // PATCH update car
  Future<CarModel> updateCar(int carId, CarModel car) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService().patchWithToken('cars/$carId/', car.toJson());
      return CarModel.fromJson(response.data);
    } catch (e) {
      print('Error updating car: $e');
      rethrow;
    }
  }

  // DELETE car
  Future<bool> deleteCar(int carId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User not authenticated');
      }

      await ApiService().deleteWithToken('cars/$carId/', token);
      return true;
    } catch (e) {
      print('Error deleting car: $e');
      rethrow;
    }
  }
}
