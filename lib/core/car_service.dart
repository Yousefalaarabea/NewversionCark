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
      final token = prefs.getString('access_token');
      final userId = prefs.getString('user_id'); // حفظناه وقت اللوجين

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      // final response = await _dio.get(
      //   'cars/',
      //   options: Options(headers: {
      //     'Authorization': 'Bearer $token',
      //   }),
      // );

      final response = await ApiService().getWithToken('cars/', token!);


      final List<dynamic> data = response.data;
      return data
          .map((json) => CarModel.fromJson(json))
          .where((car) => car.ownerId == userId)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
