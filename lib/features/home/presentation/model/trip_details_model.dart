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
  // factory TripDetailsModel.fromNotificationData(Map<String, dynamic> notificationData) {
  //   print('🔍 [TripDetailsModel.fromNotificationData] Raw notification data:');
  //   print(notificationData);
  //   print('(((((((((((((((((((((((((((((((((((((((((((((((((((((((notificationData)))))))))))))))))))))))))))))))))))))))))))))))))))))))');
  //
  //   // rentalId
  //   final dynamic rawRentalId = notificationData['rentalId'];
  //   int? rentalId;
  //   if (rawRentalId is int) {
  //     rentalId = rawRentalId;
  //   } else if (rawRentalId is String) {
  //     rentalId = int.tryParse(rawRentalId);
  //   } else if (rawRentalId != null) {
  //     rentalId = int.tryParse(rawRentalId.toString());
  //   }
  //
  //   // car
  //   final car = CarModel(
  //     id: notificationData['carId'] is int ? notificationData['carId'] : int.tryParse(notificationData['carId']?.toString() ?? '0') ?? 0,
  //     brand: (notificationData['carBrand'] ?? 'غير متوفر').toString().split(' ').first,
  //     model: (notificationData['carName'] ?? 'غير متوفر').toString().split(' ').skip(1).join(' '),
  //     carType: notificationData['carType'] ?? 'غير متوفر',
  //     carCategory: notificationData['carCategory'] ?? 'غير متوفر',
  //     year: notificationData['carYear'] is int ? notificationData['carYear'] : int.tryParse(notificationData['carYear']?.toString() ?? '0') ?? 0,
  //     plateNumber: notificationData['carPlateNumber'] ?? 'غير متوفر',
  //     fuelType: notificationData['carFuelType'] ?? 'غير متوفر',
  //     transmissionType: notificationData['carTransmission'] ?? 'غير متوفر',
  //     seatingCapacity: notificationData['carSeatingCapacity'] is int ? notificationData['carSeatingCapacity'] : int.tryParse(notificationData['carSeatingCapacity']?.toString() ?? '0') ?? 0,
  //     color: notificationData['carColor'] ?? 'غير متوفر',
  //     currentOdometerReading: notificationData['carCurrentOdometer'] is int ? notificationData['carCurrentOdometer'] : int.tryParse(notificationData['carCurrentOdometer']?.toString() ?? '0') ?? 0,
  //     availability: true,
  //     currentStatus: notificationData['currentStatus'] ?? 'غير متوفر',
  //     approvalStatus: true,
  //     ownerId: notificationData['ownerId']?.toString() ?? '',
  //     avgRating: 0.0,
  //     totalReviews: 0,
  //     imageUrl: notificationData['carDetails']?['images']?[0]?['url'] ?? '',
  //   );
  //
  //   return TripDetailsModel(
  //     car: car,
  //     rentalId: rentalId,
  //     pickupLocation: notificationData['pickupAddress'] ?? notificationData['pickupLocation'] ?? 'غير متوفر',
  //     dropoffLocation: notificationData['dropoffAddress'] ?? notificationData['dropoffLocation'] ?? 'غير متوفر',
  //     startDate: DateTime.tryParse(notificationData['startDate']?.toString() ?? '') ?? DateTime.now(),
  //     endDate: DateTime.tryParse(notificationData['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1)),
  //     totalPrice: (notificationData['totalAmount'] is num)
  //         ? (notificationData['totalAmount'] as num).toDouble()
  //         : (notificationData['totalPrice'] is num)
  //             ? (notificationData['totalPrice'] as num).toDouble()
  //             : double.tryParse(notificationData['totalAmount']?.toString() ?? '') ?? double.tryParse(notificationData['totalPrice']?.toString() ?? '') ?? 0.0,
  //     paymentMethod: notificationData['paymentMethod'] ?? 'غير متوفر',
  //     renterName: notificationData['renterDetails']?['name'] ?? 'غير متوفر',
  //     ownerName: notificationData['ownerDetails']?['name'] ?? 'غير متوفر',
  //     pickupLocationLat: (notificationData['pickupLatitude'] is num)
  //         ? (notificationData['pickupLatitude'] as num).toDouble()
  //         : double.tryParse(notificationData['pickupLatitude']?.toString() ?? ''),
  //     pickupLocationLng: (notificationData['pickupLongitude'] is num)
  //         ? (notificationData['pickupLongitude'] as num).toDouble()
  //         : double.tryParse(notificationData['pickupLongitude']?.toString() ?? ''),
  //     extraInstructions: notificationData['extraInstructions'] ?? '',
  //   );
  // }

  factory TripDetailsModel.fromNotificationData(Map<String, dynamic> notificationData) {
    try {
      print('🔍 [TripDetailsModel.fromNotificationData] Raw notification data:');
      print(notificationData);

      final carMap = notificationData['carDetails'] ?? {};
      final renterMap = notificationData['renterDetails'] ?? {};
      final ownerMap = notificationData['ownerDetails'] ?? {};

      // rentalId
      final dynamic rawRentalId = notificationData['rentalId'];
      final int? rentalId = (rawRentalId is int)
          ? rawRentalId
          : int.tryParse(rawRentalId?.toString() ?? '');

      // ✅ Safe imageUrl extraction
      String imageUrl = '';
      if (carMap['images'] is List && (carMap['images'] as List).isNotEmpty) {
        final first = (carMap['images'] as List)[0];
        if (first is Map && first['url'] != null) {
          imageUrl = first['url'].toString();
        }
      }

      final car = CarModel(
        id: notificationData['carId'] is int
            ? notificationData['carId']
            : int.tryParse(notificationData['carId']?.toString() ?? '0') ?? 0,
        brand: carMap['brand']?.toString() ?? 'غير متوفر',
        model: carMap['model']?.toString() ?? 'غير متوفر',
        carType: carMap['carType']?.toString() ?? 'غير متوفر',
        carCategory: carMap['carCategory']?.toString() ?? 'غير متوفر',
        year: carMap['year'] is int
            ? carMap['year']
            : int.tryParse(carMap['year']?.toString() ?? '0') ?? 0,
        plateNumber: carMap['plateNumber']?.toString() ?? 'غير متوفر',
        fuelType: carMap['fuelType']?.toString() ?? 'غير متوفر',
        transmissionType: carMap['transmissionType']?.toString() ?? 'غير متوفر',
        seatingCapacity: carMap['seatingCapacity'] is int
            ? carMap['seatingCapacity']
            : int.tryParse(carMap['seatingCapacity']?.toString() ?? '0') ?? 0,
        color: carMap['color']?.toString() ?? 'غير متوفر',
        currentOdometerReading: carMap['currentOdometer'] is num
            ? (carMap['currentOdometer'] as num).toInt()
            : int.tryParse(carMap['currentOdometer']?.toString() ?? '0') ?? 0,
        imageUrl: imageUrl,
        avgRating: (carMap['avgRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews: carMap['totalReviews'] is int ? carMap['totalReviews'] : 0,
        availability: true,
        currentStatus: notificationData['currentStatus']?.toString() ?? 'غير متوفر',
        approvalStatus: true,
        ownerId: notificationData['ownerId']?.toString() ?? '',
      );

      // 🧠 Debug types before assignment
      print("✔️ paymentMethod: ${notificationData['paymentMethod']} (${notificationData['paymentMethod']?.runtimeType})");
      print("✔️ renterName: ${renterMap['name']} (${renterMap['name']?.runtimeType})");
      print("✔️ ownerName: ${ownerMap['name']} (${ownerMap['name']?.runtimeType})");

      return TripDetailsModel(
        car: car,
        rentalId: rentalId,
        pickupLocation: notificationData['pickupAddress']?.toString()
            ?? notificationData['pickupLocation']?.toString()
            ?? 'غير متوفر',
        dropoffLocation: notificationData['dropoffAddress']?.toString()
            ?? notificationData['dropoffLocation']?.toString()
            ?? 'غير متوفر',
        startDate: DateTime.tryParse(notificationData['startDate']?.toString() ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(notificationData['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1)),
        totalPrice: (notificationData['totalAmount'] is num)
            ? (notificationData['totalAmount'] as num).toDouble()
            : (notificationData['totalPrice'] is num)
            ? (notificationData['totalPrice'] as num).toDouble()
            : double.tryParse(notificationData['totalAmount']?.toString() ?? '')
            ?? double.tryParse(notificationData['totalPrice']?.toString() ?? '')
            ?? 0.0,
        paymentMethod: notificationData['paymentMethod']?.toString() ?? 'غير متوفر',
        renterName: renterMap['name']?.toString() ?? 'غير متوفر',
        ownerName: ownerMap['name']?.toString() ?? 'غير متوفر',
        pickupLocationLat: (notificationData['pickupLatitude'] is num)
            ? (notificationData['pickupLatitude'] as num).toDouble()
            : double.tryParse(notificationData['pickupLatitude']?.toString() ?? ''),
        pickupLocationLng: (notificationData['pickupLongitude'] is num)
            ? (notificationData['pickupLongitude'] as num).toDouble()
            : double.tryParse(notificationData['pickupLongitude']?.toString() ?? ''),
        extraInstructions: notificationData['extraInstructions']?.toString() ?? '',
      );
    } catch (e, st) {
      print('❌ TripDetailsModel parsing failed: $e');
      print('📌 StackTrace:\n$st');
      rethrow;
    }
  }


} 