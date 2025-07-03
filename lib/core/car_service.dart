// ✅ الخطوة 1: Service جديد لجلب العربيات

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';

import 'api_service.dart';

class CarService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://cark-f3fjembga0f6btek.uaenorth-01.azurewebsites.net/api/',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),

  );


  Future<List<CarModel>> fetchUserCars() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id'); // حفظناه وقت اللوجين

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Try with admin token first
      try {
        print('Fetching user cars using admin token...');
        final response = await ApiService().getWithAdminToken('cars/');
        
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data;
          final userCars = data
              .map((json) => CarModel.fromJson(json))
              .where((car) => car.ownerId == userId)
              .toList();
          
          print('Successfully fetched ${userCars.length} cars using admin token');
          return userCars;
        } else {
          print('Failed to fetch cars with admin token, status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching cars with admin token: $e');
      }

      // Fallback to user token if admin token fails
      final token = prefs.getString('access_token');
      if (token != null) {
        try {
          print('Fetching user cars using user token...');
          final response = await ApiService().getWithToken('cars/', token);
          
          if (response.statusCode == 200) {
            final List<dynamic> data = response.data;
            final userCars = data
                .map((json) => CarModel.fromJson(json))
                .where((car) => car.ownerId == userId)
                .toList();
            
            print('Successfully fetched ${userCars.length} cars using user token');
            return userCars;
          } else {
            print('Failed to fetch cars with user token, status: ${response.statusCode}');
          }
        } catch (e) {
          print('Error fetching cars with user token: $e');
        }
      }

      // If both tokens fail, return empty list instead of throwing exception
      print('No cars found or authentication failed');
      return [];
      
    } catch (e) {
      print('Error in fetchUserCars: $e');
      // Return empty list instead of rethrowing to avoid breaking the UI
      return [];
    }
  }

  // Add car with admin token
  Future<bool> addCar(Map<String, dynamic> carData) async {
    try {
      print('Adding car using admin token...');
      final response = await ApiService().postWithAdminToken('cars/', carData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Car added successfully using admin token');
        return true;
      } else {
        print('Failed to add car with admin token, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding car with admin token: $e');
    }

    // Fallback to user token
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null) {
        print('Adding car using user token...');
        final response = await ApiService().postWithToken('cars/', carData);
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Car added successfully using user token');
          return true;
        } else {
          print('Failed to add car with user token, status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error adding car with user token: $e');
    }

    return false;
  }

  // Update car with admin token
  Future<bool> updateCar(String carId, Map<String, dynamic> carData) async {
    try {
      print('Updating car using admin token...');
      final response = await ApiService().patchWithAdminToken('cars/$carId/', carData);
      
      if (response.statusCode == 200) {
        print('Car updated successfully using admin token');
        return true;
      } else {
        print('Failed to update car with admin token, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating car with admin token: $e');
    }

    // Fallback to user token
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null) {
        print('Updating car using user token...');
        final response = await ApiService().patchWithToken('cars/$carId/', carData);
        
        if (response.statusCode == 200) {
          print('Car updated successfully using user token');
          return true;
        } else {
          print('Failed to update car with user token, status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error updating car with user token: $e');
    }

    return false;
  }

  // Delete car with admin token
  Future<bool> deleteCar(String carId) async {
    try {
      print('Deleting car using admin token...');
      final response = await ApiService().deleteWithAdminToken('cars/$carId/');
      
      if (response.statusCode == 204 || response.statusCode == 200) {
        print('Car deleted successfully using admin token');
        return true;
      } else {
        print('Failed to delete car with admin token, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting car with admin token: $e');
    }

    // Fallback to user token
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null) {
        print('Deleting car using user token...');
        final response = await ApiService().deleteWithToken('cars/$carId/', token);
        
        if (response.statusCode == 204 || response.statusCode == 200) {
          print('Car deleted successfully using user token');
          return true;
        } else {
          print('Failed to delete car with user token, status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error deleting car with user token: $e');
    }

    return false;
  }

  // Get car details with admin token
  Future<CarModel?> getCarDetails(String carId) async {
    try {
      print('Getting car details using admin token...');
      final response = await ApiService().getWithAdminToken('cars/$carId/');
      
      if (response.statusCode == 200) {
        final car = CarModel.fromJson(response.data);
        print('Car details fetched successfully using admin token');
        return car;
      } else {
        print('Failed to get car details with admin token, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting car details with admin token: $e');
    }

    // Fallback to user token
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token != null) {
        print('Getting car details using user token...');
        final response = await ApiService().getWithToken('cars/$carId/', token);
        
        if (response.statusCode == 200) {
          final car = CarModel.fromJson(response.data);
          print('Car details fetched successfully using user token');
          return car;
        } else {
          print('Failed to get car details with user token, status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error getting car details with user token: $e');
    }

    return null;
  }
}