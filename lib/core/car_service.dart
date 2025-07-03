// ✅ الخطوة 1: Service جديد لجلب العربيات

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:test_cark/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/cars/presentation/cubits/add_car_cubit.dart';
import 'api_service.dart';

class CarService {
  final Dio _dio = Dio(
    BaseOptions(
      //baseUrl: 'https://cark-f3fjembga0f6btek.uaenorth-01.azurewebsites.net/api/',
      baseUrl: 'https://start-heading-ships-translations.trycloudflare.com/api/',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Fetch all cars for the user, with their rental options and usage policy
  Future<List<Map<String, dynamic>>> fetchUserCars() async {
    final List<Map<String, dynamic>> result = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('User access token not found');
      }
      print('Fetching user cars from /my-cars/ using user token...');
      final response = await ApiService().getWithToken('my-cars/', token);
      if (response.statusCode == 200) {
        final data = response.data;
        for (final carJson in data) {
          final car = CarModel.fromJson(carJson);
          CarRentalOptions? rentalOptions;
          CarUsagePolicy? usagePolicy;
          // يمكن لاحقاً جلب rentalOptions و usagePolicy إذا احتجت
          result.add({
            'car': car,
            'rentalOptions': rentalOptions,
            'usagePolicy': usagePolicy,
          });
        }
      } else {
        print('Failed to fetch user cars, status: \\${response.statusCode}');
      }
      return result;
    } catch (e) {
      print('Error in fetchUserCars: $e');
      return [];
    }
  }

  // Fetch all available cars in the system for home screen
  Future<List<Map<String, dynamic>>> fetchAllCars() async {

    final List<Map<String, dynamic>> result = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_access_token');
      if (adminToken == null) {
        throw Exception('User access token not found');
      }
      print('Fetching All cars from /available-cars/ using user token...');
      final response = await ApiService().getWithToken('available-cars/', adminToken);
      if (response.statusCode == 200) {
        final data = response.data;
        for (final carJson in data) {
          final car = CarModel.fromJson(carJson);
          // Only include cars that are available and approved
          if (car.availability && car.approvalStatus) {
            CarRentalOptions? rentalOptions;
            CarUsagePolicy? usagePolicy;
            // يمكن لاحقاً جلب rentalOptions و usagePolicy إذا احتجت
            result.add({
              'car': car,
              'rentalOptions': rentalOptions,
              'usagePolicy': usagePolicy,
            });
          }
        }
        print('✅ Successfully fetched ${result.length} available cars');
      } else {
        print('❌ Failed to fetch available cars, status: ${response.statusCode}');
      }
      return result;
    } catch (e) {
      print('❌ Error in fetchAllCars: $e');
      return [];
    }
  }

  // Add car separately
  Future<Response?> postCar(Map<String, dynamic> carData, {bool useAdminToken = false}) async {
    try {
      if (useAdminToken) {
        print('Posting car using admin token...');
        return await ApiService().postWithAdminToken('cars/', carData);
      } else {
        print('Posting car using user token...');
        return await ApiService().postWithToken('cars/', carData);
      }
    } catch (e) {
      print('Error posting car: $e');
      return null;
    }
  }

// Add rental options separately
  Future<Response?> postRentalOptions(String carId, Map<String, dynamic> rentalOptionsData, {bool useAdminToken = false}) async {
    try {
      final endpoint = useAdminToken ? 'car-rental-options/' : 'car-rental-options/';
      final data = {
        ...rentalOptionsData,
        'car': carId,
      };
      print('Posting rental options to $endpoint...');
      return useAdminToken
          ? await ApiService().postWithAdminToken(endpoint, data)
          : await ApiService().postWithToken(endpoint, data);
    } catch (e) {
      print('Error posting rental options: $e');
      return null;
    }
  }

// Add usage policy separately
  Future<Response?> postUsagePolicy(String carId, Map<String, dynamic> usagePolicyData, {bool useAdminToken = false}) async {
    try {
      final endpoint = useAdminToken ? 'car-usage-policy/' : 'car-usage-policy/';
      final data = {
        ...usagePolicyData,
        'car': carId,
      };
      print('Posting usage policy to $endpoint...');
      return useAdminToken
          ? await ApiService().postWithAdminToken(endpoint, data)
          : await ApiService().postWithToken(endpoint, data);
    } catch (e) {
      print('Error posting usage policy: $e');
      return null;
    }
  }


  Future<bool> addCar({
    required Map<String, dynamic> carData,
    required Map<String, dynamic> rentalOptionsData,
    required Map<String, dynamic> usagePolicyData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final adminToken = prefs.getString('admin_access_token');
    final userToken = prefs.getString('access_token');
    final useAdmin = adminToken != null;

    final carResponse = await postCar(carData, useAdminToken: useAdmin);
    if (carResponse != null && (carResponse.statusCode == 201 || carResponse.statusCode == 200)) {
      final carId = carResponse.data['id'].toString();
      print('✅ Car added successfully: ID = $carId');

      final rentalRes = await postRentalOptions(carId, rentalOptionsData, useAdminToken: useAdmin);
      print('Rental Options Response: ${rentalRes?.statusCode} | ${rentalRes?.data}');

      final policyRes = await postUsagePolicy(carId, usagePolicyData, useAdminToken: useAdmin);
      print('Usage Policy Response: ${policyRes?.statusCode} | ${policyRes?.data}');

      return true;
    } else {
      print('❌ Failed to add car. Response: ${carResponse?.statusCode} | ${carResponse?.data}');
    }

    return false;
  }





  // Update car, rental options, and usage policy
  Future<bool> updateCar({
    required String carId,
    required Map<String, dynamic> carData,
    required Map<String, dynamic> rentalOptionsData,
    required Map<String, dynamic> usagePolicyData,
  }) async {
    try {
      print('Updating car using admin token...');
      final carRes = await ApiService().patchWithAdminToken('cars/$carId/', carData);
      final rentalRes = await ApiService().patchWithAdminToken('car-rental-options/$carId/', rentalOptionsData);
      final usageRes = await ApiService().patchWithAdminToken('car-usage-policy/$carId/', usagePolicyData);
      if (carRes.statusCode == 200 && rentalRes.statusCode == 200 && usageRes.statusCode == 200) {
        print('Car, rental options, and usage policy updated successfully');
        return true;
      } else {
        print('Failed to update car or related data');
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
        final carRes = await ApiService().patchWithToken('cars/$carId/', carData);
        final rentalRes = await ApiService().patchWithToken('car-rental-options/$carId/', rentalOptionsData);
        final usageRes = await ApiService().patchWithToken('car-usage-policy/$carId/', usagePolicyData);
        if (carRes.statusCode == 200 && rentalRes.statusCode == 200 && usageRes.statusCode == 200) {
          print('Car, rental options, and usage policy updated successfully (user token)');
          return true;
        } else {
          print('Failed to update car or related data (user token)');
        }
      }
    } catch (e) {
      print('Error updating car with user token: $e');
    }
    return false;
  }

  // Delete car (rental options and usage policy will be deleted by cascade)
  Future<bool> deleteCar(String carId) async {
    try {
      print('Deleting car using admin token...');
      final response = await ApiService().deleteWithAdminToken('cars/$carId/');
      if (response.statusCode == 204 || response.statusCode == 200) {
        print('Car deleted successfully using admin token');
        return true;
      } else {
        print('Failed to delete car with admin token, status: \\${response.statusCode}');
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
          print('Failed to delete car with user token, status: \\${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error deleting car with user token: $e');
    }
    return false;
  }

  // Get car details (car, rental options, usage policy)
  Future<Map<String, dynamic>?> getCarDetails(String carId) async {
    try {
      print('Getting car details using admin token...');
      final carRes = await ApiService().getWithAdminToken('cars/$carId/');
      if (carRes.statusCode == 200) {
        final car = CarModel.fromJson(carRes.data);
        CarRentalOptions? rentalOptions;
        CarUsagePolicy? usagePolicy;
        try {
          final rentalRes = await ApiService().getWithAdminToken('car-rental-options/$carId/');
          if (rentalRes.statusCode == 200) {
            rentalOptions = CarRentalOptions.fromJson(rentalRes.data);
          }
        } catch (e) {
          print('No rental options for car $carId: $e');
        }
        try {
          final usageRes = await ApiService().getWithAdminToken('car-usage-policy/$carId/');
          if (usageRes.statusCode == 200) {
            usagePolicy = CarUsagePolicy.fromJson(usageRes.data);
          }
        } catch (e) {
          print('No usage policy for car $carId: $e');
        }
        return {
          'car': car,
          'rentalOptions': rentalOptions,
          'usagePolicy': usagePolicy,
        };
      } else {
        print('Failed to get car details with admin token, status: \\${carRes.statusCode}');
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
        final carRes = await ApiService().getWithToken('cars/$carId/', token);
        if (carRes.statusCode == 200) {
          final car = CarModel.fromJson(carRes.data);
          CarRentalOptions? rentalOptions;
          CarUsagePolicy? usagePolicy;
          try {
            final rentalRes = await ApiService().getWithToken('car-rental-options/$carId/', token);
            if (rentalRes.statusCode == 200) {
              rentalOptions = CarRentalOptions.fromJson(rentalRes.data);
            }
          } catch (e) {
            print('No rental options for car $carId: $e');
          }
          try {
            final usageRes = await ApiService().getWithToken('car-usage-policy/$carId/', token);
            if (usageRes.statusCode == 200) {
              usagePolicy = CarUsagePolicy.fromJson(usageRes.data);
            }
          } catch (e) {
            print('No usage policy for car $carId: $e');
          }
          return {
            'car': car,
            'rentalOptions': rentalOptions,
            'usagePolicy': usagePolicy,
          };
        } else {
          print('Failed to get car details with user token, status: \\${carRes.statusCode}');
        }
      }
    } catch (e) {
      print('Error getting car details with user token: $e');
    }
    return null;
  }
}