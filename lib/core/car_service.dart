// ✅ الخطوة 1: Service جديد لجلب العربيات

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/api_service.dart';
// import 'package:test_cark/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';

import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/cars/presentation/cubits/add_car_cubit.dart';
import 'api_service.dart';

class CarService {
  final Dio _dio = Dio(
    BaseOptions(
      //baseUrl: 'https://cark-f3fjembga0f6btek.uaenorth-01.azurewebsites.net/api/',
      baseUrl: 'https://brandon-moderators-thorough-strict.trycloudflare.com/api/',
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
        print("🔍 User cars response data type: ${response.data.runtimeType}");
        print("🔍 User cars response data: ${response.data}");
        
        List carsData;
        if (response.data is Map) {
          // If response is a Map, try to extract the list from it
          final data = response.data as Map;
          if (data.containsKey('results')) {
            carsData = List.from(data['results']);
          } else if (data.containsKey('data')) {
            carsData = List.from(data['data']);
          } else {
            print("❌ Unexpected user cars response format");
            return [];
          }
        } else if (response.data is List) {
          carsData = List.from(response.data);
        } else {
          print("❌ Unexpected user cars response format");
          return [];
        }
        
        print("🔍 Total cars fetched from API: ${carsData.length}");
        
        for (final carJson in carsData) {
          final car = CarModel.fromJson(carJson);
          print("🔍 Car owner ID: "+ car.ownerId.toString() + " (this is the user ID who owns the car)");
          print("🔍 Car availability: "+ car.availability.toString() + ", approval status: "+ car.approvalStatus.toString());
          print("🔍 Car model: "+ car.model.toString() + ", brand: "+ car.brand.toString());
          print("🔍 Full carJson: " + carJson.toString());
          // Include cars that are available (approval status can be false for now)
          if (car.availability) {
            print("✅ Car is available, adding to result list");
            CarRentalOptions? rentalOptions;
            CarUsagePolicy? usagePolicy;
            // يمكن لاحقاً جلب rentalOptions و usagePolicy إذا احتجت
            result.add({
              'car': car,
              'carJson': carJson,
              'rentalOptions': rentalOptions,
              'usagePolicy': usagePolicy,
            });
          } else {
            print("❌ Car is not available, skipping");
          }
        }
      } else {
        print('Failed to fetch user cars, status: ${response.statusCode}');
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
      final token = prefs.getString('admin_access_token');
      if (token == null) {
        throw Exception('User access token not found');
      }
      print('Fetching all available cars from /cars/ using user token...');
      final response = await ApiService().getWithToken('cars/', token);
      if (response.statusCode == 200) {
        print("🔍 Cars response data type: ${response.data.runtimeType}");
        print("🔍 Cars response data: ${response.data}");
        
        // Debug: Check user roles to understand the difference
        await debugUserRoles();
        
        List carsData;
        if (response.data is Map) {
          // If response is a Map, try to extract the list from it
          final data = response.data as Map;
          if (data.containsKey('results')) {
            carsData = List.from(data['results']);
          } else if (data.containsKey('data')) {
            carsData = List.from(data['data']);
          } else {
            print("❌ Unexpected cars response format");
            return [];
          }
        } else if (response.data is List) {
          carsData = List.from(response.data);
        } else {
          print("❌ Unexpected cars response format");
          return [];
        }
        
        print("🔍 Total cars fetched from API: ${carsData.length}");
        
        for (final carJson in carsData) {
          final car = CarModel.fromJson(carJson);
          print("🔍 Car owner ID: ${car.ownerId} (this is the user ID who owns the car)");
          print("🔍 Car availability: ${car.availability}, approval status: ${car.approvalStatus}");
          print("🔍 Car model: ${car.model}, brand: ${car.brand}");
          print("🔍 Full carJson: " + carJson.toString());
          // Include cars that are available (approval status can be false for now)
          if (car.availability) {
            print("✅ Car is available, adding to result list");
            CarRentalOptions? rentalOptions;
            CarUsagePolicy? usagePolicy;
            // يمكن لاحقاً جلب rentalOptions و usagePolicy إذا احتجت
            result.add({
              'car': car,
              'carJson': carJson,
              'rentalOptions': rentalOptions,
              'usagePolicy': usagePolicy,
            });
          } else {
            print("❌ Car is not available, skipping");
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
        return await ApiService().postWithToken('cars/', carData);
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
          ? await ApiService().postWithToken(endpoint, data)
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
          ? await ApiService().postWithToken(endpoint, data)
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

      // ✅ Get userId from AuthCubit
      final authCubit = BlocProvider.of<AuthCubit>(navigatorKey.currentContext!);
      await authCubit.loadUserData();
      final userId = authCubit.userModel?.id;

      // ✅ Call assign role if userId is valid
      if (userId != null) {
        // Check if this is the first car (assign owner role)
        await assignRoleOwner(userId );
        
        // Check if "with driver" option is selected (assign driver role)
        final hasWithDriverOption = rentalOptionsData['available_with_driver'] == true;
        if (hasWithDriverOption) {
          print("🚗 With driver option selected - assigning driver role");
          await assignRoleDriver(userId );
        }
      } else {
        print("❌ userId not found. Cannot assign role.");
      }

      return true;
    } else {
      print('❌ Failed to add car. Response: ${carResponse?.statusCode} | ${carResponse?.data}');
    }

    return false;
  }


  Future<void> assignRoleOwner(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_access_token');
      if (adminToken == null) {
        print("❌ Admin token not found. Cannot assign owner role.");
        return;
      }

      // Get current roles (you may want to GET user-role/ to check if already has Owner)
      final rolesResponse = await ApiService().getWithAdminToken("user-roles/");
      print("🔍 Roles response data type: ${rolesResponse.data.runtimeType}");
      print("🔍 Roles response data: ${rolesResponse.data}");
      
      List roles;
      if (rolesResponse.data is Map) {
        // If response is a Map, try to extract the list from it
        final data = rolesResponse.data as Map;
        if (data.containsKey('results')) {
          roles = List.from(data['results']);
        } else if (data.containsKey('data')) {
          roles = List.from(data['data']);
        } else {
          // If it's a Map but no known structure, try to convert it to a list
          roles = [data];
        }
      } else if (rolesResponse.data is List) {
        roles = List.from(rolesResponse.data);
      } else {
        print("❌ Unexpected response format for user roles");
        return;
      }

      print("🔍 Processed roles list: $roles");

      final hasOwnerRole = roles.any((role) =>
          role['user'].toString() == userId && role['role'] == 2);

      final isRenterOnly = roles.any((role) =>
          role['user'].toString() == userId && role['role'] == 1) &&
          !hasOwnerRole;

      print("🔍 Has owner role: $hasOwnerRole");
      print("🔍 Is renter only: $isRenterOnly");

      if (isRenterOnly) {
        final response = await ApiService().postWithAdminToken("user-roles/", {
          "user": int.parse(userId),
          "role": 2, // Owner
        });

        if (response.statusCode == 201 || response.statusCode == 200) {
          print("✅ Owner role assigned to user $userId");
        } else {
          print("❌ Failed to assign Owner role. Status: ${response.statusCode}");
          print("❌ Response data: ${response.data}");
        }
      } else {
        print("ℹ️ User already has Owner role or is not just a Renter.");
      }
    } catch (e) {
      print("❌ Error assigning Owner role: $e");
    }
  }

  Future<void> assignRoleDriver(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_access_token');
      if (adminToken == null) {
        print("❌ Admin token not found. Cannot assign driver role.");
        return;
      }

      // Get current roles to check if already has Driver role
      final rolesResponse = await ApiService().getWithAdminToken("user-roles/");
      print("🔍 Driver roles response data type: ${rolesResponse.data.runtimeType}");
      print("🔍 Driver roles response data: ${rolesResponse.data}");
      
      List roles;
      if (rolesResponse.data is Map) {
        // If response is a Map, try to extract the list from it
        final data = rolesResponse.data as Map;
        if (data.containsKey('results')) {
          roles = List.from(data['results']);
        } else if (data.containsKey('data')) {
          roles = List.from(data['data']);
        } else {
          // If it's a Map but no known structure, try to convert it to a list
          roles = [data];
        }
      } else if (rolesResponse.data is List) {
        roles = List.from(rolesResponse.data);
      } else {
        print("❌ Unexpected response format for user roles");
        return;
      }

      print("🔍 Processed driver roles list: $roles");

      final hasDriverRole = roles.any((role) =>
          role['user'].toString() == userId && role['role'] == 3);

      print("🔍 Has driver role: $hasDriverRole");

      if (!hasDriverRole) {
        final response = await ApiService().postWithAdminToken("user-roles/", {
          "user": int.parse(userId),
          "role": 3, // Driver
        });

        if (response.statusCode == 201 || response.statusCode == 200) {
          print("✅ Driver role assigned to user $userId");
        } else {
          print("❌ Failed to assign Driver role. Status: ${response.statusCode}");
          print("❌ Response data: ${response.data}");
        }
      } else {
        print("ℹ️ User already has Driver role.");
      }
    } catch (e) {
      print("❌ Error assigning Driver role: $e");
    }
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
      final carRes = await ApiService().patchWithToken('cars/$carId/', carData);
      final rentalRes = await ApiService().patchWithToken('car-rental-options/$carId/', rentalOptionsData);
      final usageRes = await ApiService().patchWithToken('car-usage-policy/$carId/', usagePolicyData);
      if (carRes.statusCode == 200 && rentalRes.statusCode == 200 && usageRes.statusCode == 200) {
        print('Car, rental options, and usage policy updated successfully');
        
        // ✅ Check for role assignment after successful update
        final authCubit = BlocProvider.of<AuthCubit>(navigatorKey.currentContext!);
        await authCubit.loadUserData();
        final userId = authCubit.userModel?.id;

        if (userId != null) {
          // Check if "with driver" option is selected (assign driver role)
          final hasWithDriverOption = rentalOptionsData['available_with_driver'] == true;
          if (hasWithDriverOption) {
            print("🚗 With driver option selected during update - assigning driver role");
            await assignRoleDriver(userId);
          }
        }
        
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
          
          // ✅ Check for role assignment after successful update
          final authCubit = BlocProvider.of<AuthCubit>(navigatorKey.currentContext!);
          await authCubit.loadUserData();
          final userId = authCubit.userModel?.id;

          if (userId != null) {
            // Check if "with driver" option is selected (assign driver role)
            final hasWithDriverOption = rentalOptionsData['available_with_driver'] == true;
            if (hasWithDriverOption) {
              print("🚗 With driver option selected during update - assigning driver role");
              await assignRoleDriver(userId);
            }
          }
          
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

  // Debug function to check user roles
  Future<void> debugUserRoles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_access_token');
      if (adminToken == null) {
        print("❌ Admin token not found. Cannot check user roles.");
        return;
      }

      print("🔍 Checking all user roles...");
      final rolesResponse = await ApiService().getWithAdminToken("user-roles/");
      print("🔍 Roles response data type: ${rolesResponse.data.runtimeType}");
      print("🔍 Roles response data: ${rolesResponse.data}");
      
      List roles;
      if (rolesResponse.data is Map) {
        final data = rolesResponse.data as Map;
        if (data.containsKey('results')) {
          roles = List.from(data['results']);
        } else if (data.containsKey('data')) {
          roles = List.from(data['data']);
        } else {
          roles = [data];
        }
      } else if (rolesResponse.data is List) {
        roles = List.from(rolesResponse.data);
      } else {
        print("❌ Unexpected response format for user roles");
        return;
      }

      print("🔍 All user roles:");
      for (final role in roles) {
        final userId = role['user'];
        final roleId = role['role'];
        String roleName = '';
        switch (roleId) {
          case 1:
            roleName = 'Renter';
            break;
          case 2:
            roleName = 'Owner';
            break;
          case 3:
            roleName = 'Driver';
            break;
          default:
            roleName = 'Unknown';
        }
        print("   User ID: $userId → Role: $roleId ($roleName)");
      }
    } catch (e) {
      print("❌ Error checking user roles: $e");
    }
  }
}