import '../../../cars/presentation/models/car_usage_policy.dart';

class CarModel {
  final String ownerId;
  final int id;
  final String model;
  final String brand;
  final String carType;
  final String carCategory;
  final String plateNumber;
  final int year;
  final String color;
  final int seatingCapacity;
  final String transmissionType;
  final String fuelType;
  final int currentOdometerReading;
  final bool availability;
  final String currentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool approvalStatus;
  final double avgRating;
  final int totalReviews;
  final String? imageUrl;

  CarModel({
    required this.ownerId,
    required this.id,
    required this.model,
    required this.brand,
    required this.carType,
    required this.carCategory,
    required this.plateNumber,
    required this.year,
    required this.color,
    required this.seatingCapacity,
    required this.transmissionType,
    required this.fuelType,
    required this.currentOdometerReading,
    required this.availability,
    required this.currentStatus,
    this.createdAt,
    this.updatedAt,
    required this.approvalStatus,
    required this.avgRating,
    required this.totalReviews,
    this.imageUrl,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = (json['images'] as List).first['url'] as String?;
    } else {
      imageUrl = json['image_url'];
    }
    return CarModel(
      ownerId: json['owner'].toString(),
      id: json['id'],
      model: json['model'],
      brand: json['brand'],
      carType: json['car_type'],
      carCategory: json['car_category'],
      plateNumber: json['plate_number'],
      year: json['year'],
      color: json['color'],
      seatingCapacity: json['seating_capacity'],
      transmissionType: json['transmission_type'],
      fuelType: json['fuel_type'],
      currentOdometerReading: json['current_odometer_reading'],
      availability: json['availability'],
      currentStatus: json['current_status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      approvalStatus: json['approval_status'],
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'ownerId': ownerId,
    'id': id,
    'model': model,
    'brand': brand,
    'car_type': carType,
    'car_category': carCategory,
    'plate_number': plateNumber,
    'year': year,
    'color': color,
    'seating_capacity': seatingCapacity,
    'transmission_type': transmissionType,
    'fuel_type': fuelType,
    'current_odometer_reading': currentOdometerReading,
    'availability': availability,
    'current_status': currentStatus,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'approval_status': approvalStatus,
    'avg_rating': avgRating,
    'total_reviews': totalReviews,
    'image_url': imageUrl,
  };
}

class RentalOptions {
  final bool availableWithoutDriver;
  final bool availableWithDriver;
  final double? dailyRentalPrice;
  final double? monthlyRentalPrice;
  final double? yearlyRentalPrice;
  final double? dailyRentalPriceWithDriver;
  final double? monthlyPriceWithDriver;
  final double? yearlyPriceWithDriver;

  RentalOptions({
    required this.availableWithoutDriver,
    required this.availableWithDriver,
    this.dailyRentalPrice,
    this.monthlyRentalPrice,
    this.yearlyRentalPrice,
    this.dailyRentalPriceWithDriver,
    this.monthlyPriceWithDriver,
    this.yearlyPriceWithDriver,
  });

  factory RentalOptions.fromJson(Map<String, dynamic> json) {
    return RentalOptions(
      availableWithoutDriver: json['available_without_driver'],
      availableWithDriver: json['available_with_driver'],
      dailyRentalPrice: json['daily_rental_price']?.toDouble(),
      monthlyRentalPrice: json['monthly_rental_price']?.toDouble(),
      yearlyRentalPrice: json['yearly_rental_price']?.toDouble(),
      dailyRentalPriceWithDriver: json['daily_rental_price_with_driver']?.toDouble(),
      monthlyPriceWithDriver: json['monthly_price_with_driver']?.toDouble(),
      yearlyPriceWithDriver: json['yearly_price_with_driver']?.toDouble(),
    );
  }

  factory RentalOptions.mock() {
    return RentalOptions(
      availableWithoutDriver: true,
      availableWithDriver: true,
      dailyRentalPrice: 200.0,
      dailyRentalPriceWithDriver: 250.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'available_without_driver': availableWithoutDriver,
    'available_with_driver': availableWithDriver,
    'daily_rental_price': dailyRentalPrice,
    'monthly_rental_price': monthlyRentalPrice,
    'yearly_rental_price': yearlyRentalPrice,
    'daily_rental_price_with_driver': dailyRentalPriceWithDriver,
    'monthly_price_with_driver': monthlyPriceWithDriver,
    'yearly_price_with_driver': yearlyPriceWithDriver,
  };
}