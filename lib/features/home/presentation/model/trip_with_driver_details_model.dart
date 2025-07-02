import 'car_model.dart';
import 'location_model.dart';

class TripWithDriverDetailsModel {
  final CarModel car;
  final String pickupLocation;
  final String dropoffLocation;
  final List<LocationModel> stops;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String paymentMethod;
  final String renterName;
  final bool withDriver;

  TripWithDriverDetailsModel({
    required this.car,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.stops,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.paymentMethod,
    required this.renterName,
    this.withDriver = true,
  });
} 