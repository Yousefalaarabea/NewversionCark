import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/home/presentation/model/location_model.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Create a new rental booking
  Future<Map<String, dynamic>> createRental({
    required CarModel car,
    required DateTime startDate,
    required DateTime endDate,
    required String rentalType, // 'WithDriver' or 'WithoutDriver'
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    required String paymentMethod, // 'wallet', 'visa', 'cash'
    List<LocationModel>? stops, // For trips with driver
    int? selectedCardId, // For visa payments
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      // Prepare stops data
      List<Map<String, dynamic>> stopsData = [];
      if (stops != null && stops.isNotEmpty) {
        for (int i = 0; i < stops.length; i++) {
          stopsData.add({
            'stop_order': i + 1,
            'latitude': stops[i].lat ?? 0.0,
            'longitude': stops[i].lng ?? 0.0,
            'address': stops[i].name,
            'approx_waiting_time_minutes': 0, // Default value
          });
        }
      }

      // Prepare request data
      final requestData = {
        'car': car.id,
        'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
        'end_date': endDate.toIso8601String().split('T')[0],
        'rental_type': rentalType,
        'pickup_latitude': pickupLocation.lat ?? 0.0,
        'pickup_longitude': pickupLocation.lng ?? 0.0,
        'pickup_address': pickupLocation.name,
        'dropoff_latitude': dropoffLocation.lat ?? 0.0,
        'dropoff_longitude': dropoffLocation.lng ?? 0.0,
        'dropoff_address': dropoffLocation.name,
        'payment_method': 'visa',
        'stops': stopsData,
      };

      // Add selected card ID if provided
      if (selectedCardId != null) {
        requestData['selected_card'] = 1;
      }

      print('Creating rental with data: $requestData');

      final response = await _apiService.postWithToken('/selfdrive-rentals/', requestData);

      if (response.statusCode == 201) {
        print('✅ Rental created successfully: ${response.data}');
        return response.data;
      } else {
        print('❌ Failed to create rental: ${response.statusCode}');
        throw Exception('Failed to create rental: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating rental: $e');
      rethrow;
    }
  }

  // Calculate rental costs
  Future<Map<String, dynamic>> calculateRentalCosts({
    required int rentalId,
    required double plannedKm,
    required int totalWaitingMinutes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      final requestData = {
        'planned_km': plannedKm,
        'total_waiting_minutes': totalWaitingMinutes,
      };

      print('Calculating costs for rental $rentalId with data: $requestData');

      final response = await _apiService.postWithToken(
        'rentals/$rentalId/calculate_costs/',
        requestData,
      );

      if (response.statusCode == 200) {
        print('✅ Costs calculated successfully: ${response.data}');
        return response.data;
      } else {
        print('❌ Failed to calculate costs: ${response.statusCode}');
        throw Exception('Failed to calculate costs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error calculating costs: $e');
      rethrow;
    }
  }

  // Get user's rental history
  Future<List<Map<String, dynamic>>> getUserRentals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      print('Fetching user rentals...');

      final response = await _apiService.getWithToken('rentals/', token);

      if (response.statusCode == 200) {
        print('✅ User rentals fetched successfully: ${response.data.length} rentals');
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        print('❌ Failed to fetch user rentals: ${response.statusCode}');
        throw Exception('Failed to fetch user rentals: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching user rentals: $e');
      rethrow;
    }
  }

  // Get specific rental details
  Future<Map<String, dynamic>> getRentalDetails(int rentalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      print('Fetching rental details for ID: $rentalId');

      final response = await _apiService.getWithToken('rentals/$rentalId/', token);

      if (response.statusCode == 200) {
        print('✅ Rental details fetched successfully');
        return response.data;
      } else {
        print('❌ Failed to fetch rental details: ${response.statusCode}');
        throw Exception('Failed to fetch rental details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching rental details: $e');
      rethrow;
    }
  }

  // Confirm booking (owner action)
  Future<Map<String, dynamic>> confirmBooking(int rentalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      print('Confirming booking for rental ID: $rentalId');

      final response = await _apiService.postWithToken(
        '/selfdrive-rentals/$rentalId/confirm_by_owner/',
        {},
      );

      if (response.statusCode == 200) {
        print('✅ Booking confirmed successfully');
        return response.data;
      } else {
        print('❌ Failed to confirm booking: ${response.statusCode}');
        throw Exception('Failed to confirm booking: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error confirming booking: $e');
      rethrow;
    }
  }

  // Pay deposit
  Future<Map<String, dynamic>> payDeposit({
    required int rentalId,
    required double amount,
    String? cardId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      final requestData = {
        'amount': amount,
        if (cardId != null) 'card_id': cardId,
      };

      print('Paying deposit for rental ID: $rentalId, amount: $amount');

      final response = await _apiService.postWithToken(
        'rentals/$rentalId/deposit_payment/',
        requestData,
      );

      if (response.statusCode == 200) {
        print('✅ Deposit paid successfully');
        return response.data;
      } else {
        print('❌ Failed to pay deposit: ${response.statusCode}');
        throw Exception('Failed to pay deposit: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error paying deposit: $e');
      rethrow;
    }
  }

  // Start trip
  Future<Map<String, dynamic>> startTrip(int rentalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      print('Starting trip for rental ID: $rentalId');

      final response = await _apiService.postWithToken(
        'rentals/$rentalId/start_trip/',
        {},
      );

      if (response.statusCode == 200) {
        print('✅ Trip started successfully');
        return response.data;
      } else {
        print('❌ Failed to start trip: ${response.statusCode}');
        throw Exception('Failed to start trip: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error starting trip: $e');
      rethrow;
    }
  }

  // End trip
  Future<Map<String, dynamic>> endTrip(int rentalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      print('Ending trip for rental ID: $rentalId');

      final response = await _apiService.postWithToken(
        'rentals/$rentalId/end_trip/',
        {},
      );

      if (response.statusCode == 200) {
        print('✅ Trip ended successfully');
        return response.data;
      } else {
        print('❌ Failed to end trip: ${response.statusCode}');
        throw Exception('Failed to end trip: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error ending trip: $e');
      rethrow;
    }
  }

  // Cancel rental
  Future<Map<String, dynamic>> cancelRental(int rentalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('User access token not found');
      }

      print('Canceling rental ID: $rentalId');

      final response = await _apiService.deleteWithToken('rentals/$rentalId/', token);

      if (response.statusCode == 204) {
        print('✅ Rental canceled successfully');
        return {'message': 'Rental canceled successfully'};
      } else {
        print('❌ Failed to cancel rental: ${response.statusCode}');
        throw Exception('Failed to cancel rental: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error canceling rental: $e');
      rethrow;
    }
  }

  // Pay deposit for selfdrive rental with saved card
  Future<Map<String, dynamic>> paySelfDriveDepositWithSavedCard({
    required String rentalId,
    required String savedCardId,
    required String amountCents,
    required String paymentMethod, // should be 'saved_card'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('User access token not found');
      }
      final url = '/selfdrive-rentals/$rentalId/deposit_payment/';
      final body = {
        "saved_card_id": savedCardId,
        "amount_cents": amountCents,
        "payment_method": paymentMethod,
      };
      print('POST $url');
      print('Body: $body');
      final response = await _apiService.postWithToken(url, body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Deposit payment successful');
        return response.data;
      } else {
        print('❌ Failed to pay deposit: \\${response.statusCode}');
        throw Exception('Failed to pay deposit: \\${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error paying deposit: $e');
      rethrow;
    }
  }

  // Pay deposit for selfdrive rental with new card
  Future<Map<String, dynamic>> paySelfDriveDepositWithNewCard({
    required String rentalId,
    required String amountCents,
    required String paymentMethod, // should be 'new_card'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('User access token not found');
      }
      final url = '/selfdrive-rentals/$rentalId/new_card_deposit_payment/';
      final body = {
        "amount_cents": amountCents,
        "payment_method": paymentMethod,
      };
      print('POST $url');
      print('Body: $body');
      final response = await _apiService.postWithToken(url, body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ New card deposit payment successful');
        return response.data;
      } else {
        print('❌ Failed to pay deposit with new card: \\${response.statusCode}');
        throw Exception('Failed to pay deposit with new card: \\${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error paying deposit with new card: $e');
      rethrow;
    }
  }

  // Owner Pickup Handover (post contract image and optionally confirm_remaining_cash)
  Future<Map<String, dynamic>> ownerPickupHandover({
    required int rentalId,
    required String contractImagePath,
    bool? confirmRemainingCash,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('User access token not found');

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'contract_image': await MultipartFile.fromFile(contractImagePath),
        if (confirmRemainingCash != null) 'confirm_remaining_cash': confirmRemainingCash.toString(),
      });
      print('${ApiService().baseUrl}');


      final response = await dio.post(
        '${ApiService().baseUrl}selfdrive-rentals/$rentalId/owner_pickup_handover/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to send handover: \\${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Renter Pickup Handover (post car_image, odometer_image, odometer_value)
  Future<Map<String, dynamic>> renterPickupHandover({
    required int rentalId,
    required String carImagePath,
    required String odometerImagePath,
    required int odometerValue,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('User access token not found');

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'car_image': await MultipartFile.fromFile(carImagePath),
        'odometer_image': await MultipartFile.fromFile(odometerImagePath),
        'odometer_value': odometerValue.toString(),
      });

      final response = await dio.post(
        '${ApiService().baseUrl}selfdrive-rentals/$rentalId/renter_pickup_handover/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to send renter handover: \\${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> ownerdroppoffHandover({
    required int rentalId,
    required String carImagePath,
    required String odometerImagePath,
    required int odometerValue,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('User access token not found');

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'car_image': await MultipartFile.fromFile(carImagePath),
        'odometer_image': await MultipartFile.fromFile(odometerImagePath),
        'odometer_value': odometerValue.toString(),
      });

      final response = await dio.post(
        '${ApiService().baseUrl}selfdrive-rentals/$rentalId/renter_pickup_handover/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to send renter handover: \\${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<Map<String, dynamic>> addNewCard({
    // required String rentalId,
    required String amountCents,
    required String paymentMethod, // should be 'new_card'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('User access token not found');
      }
      final url = '/payments/start/';
      final body = {
        "amount_cents": amountCents,
        "payment_method": paymentMethod,
      };
      print('POST $url');
      print('Body: $body');
      final response = await _apiService.postWithToken(url, body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ New card deposit payment successful');
        return response.data;
      } else {
        print('❌ Failed to pay deposit with new card: \\${response.statusCode}');
        throw Exception('Failed to pay deposit with new card: \\${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error paying deposit with new card: $e');
      rethrow;
    }
  }
} 