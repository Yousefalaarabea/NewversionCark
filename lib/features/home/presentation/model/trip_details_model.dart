import 'car_model.dart';

class TripDetailsModel {
  final CarModel car;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String paymentMethod;
  final String renterName;
  final String ownerName;

  TripDetailsModel({
    required this.car,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.paymentMethod,
    required this.renterName,
    required this.ownerName,
  });
} 