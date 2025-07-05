import 'package:dio/dio.dart';
import '../features/home/model/car_rental_preview_model.dart';
import 'api_service.dart';

class CarRentalService {
  static final CarRentalService _instance = CarRentalService._internal();
  factory CarRentalService() => _instance;
  CarRentalService._internal();

  final ApiService _apiService = ApiService();

  Future<CarRentalPreviewModel> getRentalPreview({
    required int carId,
    required String startDate,
    required String endDate,
    required String pickupLatitude,
    required String pickupLongitude,
    required String pickupAddress,
    required String dropoffLatitude,
    required String dropoffLongitude,
    required String dropoffAddress,
    required String paymentMethod,
    required int selectedCard,
  }) async {
    try {
      final requestBody = {
        "car": carId,
        "start_date": startDate,
        "end_date": endDate,
        "pickup_latitude": pickupLatitude,
        "pickup_longitude": pickupLongitude,
        "pickup_address": pickupAddress,
        "dropoff_latitude": dropoffLatitude,
        "dropoff_longitude": dropoffLongitude,
        "dropoff_address": dropoffAddress,
        "payment_method": paymentMethod,
        "selected_card": selectedCard,
      };

      final response = await _apiService.postWithToken(
        'selfdrive-rentals/preview/',
        requestBody,
      );

      if (response.statusCode == 200) {
        return CarRentalPreviewModel.fromJson(response.data);
      } else {
        throw Exception('Failed to get rental preview: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting rental preview: $e');
    }
  }
} 