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
  final double? pickupLocationLat;
  final double? pickupLocationLng;
  final String? extraInstructions;

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
    this.pickupLocationLat,
    this.pickupLocationLng,
    this.extraInstructions,
  });

  Map<String, dynamic> toJson() => {
    'car': car.toJson(),
    'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalPrice': totalPrice,
    'paymentMethod': paymentMethod,
    'renterName': renterName,
    'ownerName': ownerName,
    'pickupLocationLat': pickupLocationLat,
    'pickupLocationLng': pickupLocationLng,
    'extraInstructions': extraInstructions,
  };

  factory TripDetailsModel.fromJson(Map<String, dynamic> json) => TripDetailsModel(
    car: CarModel.fromJson(json['car']),
    pickupLocation: json['pickupLocation'],
    dropoffLocation: json['dropoffLocation'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    totalPrice: (json['totalPrice'] as num).toDouble(),
    paymentMethod: json['paymentMethod'],
    renterName: json['renterName'],
    ownerName: json['ownerName'],
    pickupLocationLat: (json['pickupLocationLat'] as num?)?.toDouble(),
    pickupLocationLng: (json['pickupLocationLng'] as num?)?.toDouble(),
    extraInstructions: json['extraInstructions'],
  );
} 