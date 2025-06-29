import 'package:test_cark/features/home/presentation/model/car_model.dart';

class BookingModel {
  final CarModel car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;

  BookingModel({
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  // Mock data for a single booking
  factory BookingModel.mock() {
    return BookingModel(
      car: CarModel.mock(),
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 7)),
      totalPrice: 250.00,
      status: 'Completed',
    );
  }
} 