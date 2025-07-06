import 'car_model.dart';

class TripDetailsModel {
  final CarModel car;
  final int? rentalId;
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
    this.rentalId,
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
    'rentalId': rentalId,
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
      rentalId : json['rentalId'],
  );

  // دالة لتحويل البيانات من الإشعار إلى TripDetailsModel
  factory TripDetailsModel.fromNotificationData(Map<String, dynamic> notificationData) {
    print('🔍 [TripDetailsModel.fromNotificationData] Raw notification data:');
    print(notificationData);
    print('(((((((((((((((((((((((((((((((((((((((((((((((((((((((notificationData)))))))))))))))))))))))))))))))))))))))))))))))))))))))');

    // rentalId
    final dynamic rawRentalId = notificationData['rentalId'];
    int? rentalId;
    if (rawRentalId is int) {
      rentalId = rawRentalId;
    } else if (rawRentalId is String) {
      rentalId = int.tryParse(rawRentalId);
    } else if (rawRentalId != null) {
      rentalId = int.tryParse(rawRentalId.toString());
    }

    // car
    final car = CarModel(
      id: notificationData['carId'] is int ? notificationData['carId'] : int.tryParse(notificationData['carId']?.toString() ?? '0') ?? 0,
      brand: (notificationData['carName'] ?? 'غير متوفر').toString().split(' ').first,
      model: (notificationData['carName'] ?? 'غير متوفر').toString().split(' ').skip(1).join(' '),
      carType: notificationData['carType'] ?? 'غير متوفر',
      carCategory: notificationData['carCategory'] ?? 'غير متوفر',
      year: notificationData['year'] is int ? notificationData['year'] : int.tryParse(notificationData['year']?.toString() ?? '0') ?? 0,
      plateNumber: notificationData['plateNumber'] ?? 'غير متوفر',
      fuelType: notificationData['fuelType'] ?? 'غير متوفر',
      transmissionType: notificationData['transmissionType'] ?? 'غير متوفر',
      seatingCapacity: notificationData['seatingCapacity'] is int ? notificationData['seatingCapacity'] : int.tryParse(notificationData['seatingCapacity']?.toString() ?? '0') ?? 0,
      color: notificationData['color'] ?? 'غير متوفر',
      currentOdometerReading: notificationData['currentOdometerReading'] is int ? notificationData['currentOdometerReading'] : int.tryParse(notificationData['currentOdometerReading']?.toString() ?? '0') ?? 0,
      availability: true,
      currentStatus: notificationData['currentStatus'] ?? 'غير متوفر',
      approvalStatus: true,
      ownerId: notificationData['ownerId']?.toString() ?? '',
      avgRating: 0.0,
      totalReviews: 0,
      imageUrl: notificationData['carImageUrl'] ?? notificationData['imageUrl'] ?? '',
    );

    return TripDetailsModel(
      car: car,
      rentalId: rentalId,
      pickupLocation: notificationData['pickupAddress'] ?? notificationData['pickupLocation'] ?? 'غير متوفر',
      dropoffLocation: notificationData['dropoffAddress'] ?? notificationData['dropoffLocation'] ?? 'غير متوفر',
      startDate: DateTime.tryParse(notificationData['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(notificationData['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1)),
      totalPrice: (notificationData['totalAmount'] is num)
          ? (notificationData['totalAmount'] as num).toDouble()
          : (notificationData['totalPrice'] is num)
              ? (notificationData['totalPrice'] as num).toDouble()
              : double.tryParse(notificationData['totalAmount']?.toString() ?? '') ?? double.tryParse(notificationData['totalPrice']?.toString() ?? '') ?? 0.0,
      paymentMethod: notificationData['paymentMethod'] ?? 'غير متوفر',
      renterName: notificationData['renterName'] ?? 'غير متوفر',
      ownerName: notificationData['ownerName'] ?? 'غير متوفر',
      pickupLocationLat: (notificationData['pickupLatitude'] is num)
          ? (notificationData['pickupLatitude'] as num).toDouble()
          : double.tryParse(notificationData['pickupLatitude']?.toString() ?? ''),
      pickupLocationLng: (notificationData['pickupLongitude'] is num)
          ? (notificationData['pickupLongitude'] as num).toDouble()
          : double.tryParse(notificationData['pickupLongitude']?.toString() ?? ''),
      extraInstructions: notificationData['extraInstructions'] ?? '',
    );
  }
} 