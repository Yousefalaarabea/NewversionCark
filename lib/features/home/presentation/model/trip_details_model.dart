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
    // Debug: طباعة البيانات الواردة من الإشعار
    print('🔍 [TripDetailsModel.fromNotificationData] Raw notification data:');
    print(notificationData);
    
    // تحسين استخراج rentalId - البحث في عدة أسماء محتملة
    final dynamic rawRentalId = notificationData['rentalId'] ??
                                notificationData['rental_id'] ??
                                notificationData['id'] ??
                                notificationData['rental'];
    
    print('🔍 [TripDetailsModel.fromNotificationData] Raw rentalId: $rawRentalId (type: ${rawRentalId.runtimeType})');
    
    int? rentalId;
    if (rawRentalId is int) {
      rentalId = rawRentalId;
      print('✅ [TripDetailsModel.fromNotificationData] rentalId is int: $rentalId');
    } else if (rawRentalId is String) {
      rentalId = int.tryParse(rawRentalId);
      print('✅ [TripDetailsModel.fromNotificationData] rentalId parsed from string: $rentalId');
    } else if (rawRentalId != null) {
      // محاولة تحويل أي نوع آخر إلى string ثم إلى int
      rentalId = int.tryParse(rawRentalId.toString());
      print('✅ [TripDetailsModel.fromNotificationData] rentalId converted from ${rawRentalId.runtimeType}: $rentalId');
    } else {
      print('❌ [TripDetailsModel.fromNotificationData] No rentalId found in notification data');
    }

    // إذا لم يوجد car كـ Map، أنشئ CarModel من الحقول المتوفرة
    final car = CarModel(
      id: notificationData['carId'] ?? 0,
      brand: (notificationData['carName'] ?? '').toString().split(' ').firstOrNull ?? 'غير متوفر',
      model: (notificationData['carName'] ?? '').toString().split(' ').skip(1).join(' ') == '' ? 'غير متوفر' : (notificationData['carName'] ?? '').toString().split(' ').skip(1).join(' '),
      carType: notificationData['carType'] ?? 'غير متوفر',
      carCategory: notificationData['carCategory'] ?? 'غير متوفر',
      year: notificationData['year'] ?? 0,
      plateNumber: notificationData['plateNumber'] ?? 'غير متوفر',
      fuelType: notificationData['fuelType'] ?? 'غير متوفر',
      transmissionType: notificationData['transmissionType'] ?? 'غير متوفر',
      seatingCapacity: notificationData['seatingCapacity'] ?? 0,
      color: notificationData['color'] ?? 'غير متوفر',
      currentOdometerReading: notificationData['currentOdometerReading'] ?? 0,
      availability: true,
      currentStatus: notificationData['currentStatus'] ?? 'غير متوفر',
      approvalStatus: true,
      ownerId: notificationData['ownerId']?.toString() ?? '',
      avgRating: 0.0,
      totalReviews: 0,
      imageUrl: notificationData['carImageUrl'] ?? notificationData['imageUrl'], // إضافة صورة السيارة
    );

    final tripDetails = TripDetailsModel(
      car: car,
      rentalId: rentalId,
      pickupLocation: notificationData['pickupAddress'] ?? notificationData['pickupLocation'] ?? 'غير متوفر',
      dropoffLocation: notificationData['dropoffAddress'] ?? notificationData['dropoffLocation'] ?? 'غير متوفر',
      startDate: DateTime.tryParse(notificationData['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(notificationData['endDate'] ?? '') ?? DateTime.now(),
      totalPrice: (notificationData['totalAmount'] ?? notificationData['totalPrice'] ?? 0.0).toDouble(),
      paymentMethod: notificationData['paymentMethod'] ?? 'غير متوفر',
      renterName: notificationData['renterName'] ?? 'غير متوفر',
      ownerName: notificationData['ownerName'] ?? 'غير متوفر',
      pickupLocationLat: (notificationData['pickupLatitude'] as num?)?.toDouble(),
      pickupLocationLng: (notificationData['pickupLongitude'] as num?)?.toDouble(),
      extraInstructions: notificationData['extraInstructions'],
    );
    
    print('✅ [TripDetailsModel.fromNotificationData] Created TripDetailsModel with rentalId: ${tripDetails.rentalId}');
    return tripDetails;
  }
} 