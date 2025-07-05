class CarRentalPreviewModel {
  final CarDetails carDetails;
  final RentalDetails rentalDetails;
  final Pricing pricing;
  final UsagePolicy usagePolicy;
  final PaymentMethods paymentMethods;
  final PlatformPolicies platformPolicies;

  CarRentalPreviewModel({
    required this.carDetails,
    required this.rentalDetails,
    required this.pricing,
    required this.usagePolicy,
    required this.paymentMethods,
    required this.platformPolicies,
  });

  factory CarRentalPreviewModel.fromJson(Map<String, dynamic> json) {
    return CarRentalPreviewModel(
      carDetails: CarDetails.fromJson(json['car_details']),
      rentalDetails: RentalDetails.fromJson(json['rental_details']),
      pricing: Pricing.fromJson(json['pricing']),
      usagePolicy: UsagePolicy.fromJson(json['usage_policy']),
      paymentMethods: PaymentMethods.fromJson(json['payment_methods']),
      platformPolicies: PlatformPolicies.fromJson(json['platform_policies']),
    );
  }

  // Getter methods for easy access
  double get totalPrice => pricing.totalCost;
  double get dailyPrice => pricing.dailyPrice;
  double get baseCost => pricing.baseCost;
  double get serviceFee => pricing.serviceFee;
  double get depositAmount => pricing.depositAmount;
  double get remainingAmount => pricing.remainingAmount;
  
  // Rental details getters
  String get startDate => rentalDetails.startDate;
  String get endDate => rentalDetails.endDate;
  int get durationDays => rentalDetails.durationDays;
  String get pickupAddress => rentalDetails.pickupAddress;
  String get dropoffAddress => rentalDetails.dropoffAddress;
  
  // Usage policy getters
  double get dailyKmLimit => usagePolicy.dailyKmLimit;
  double get totalAllowedKm => usagePolicy.totalAllowedKm;
  double get extraKmCost => usagePolicy.extraKmCost;
  
  // Car details getters
  String get carBrand => carDetails.brand;
  String get carModel => carDetails.model;
  String get carColor => carDetails.color;
  String get transmissionType => carDetails.transmissionType;
  String get fuelType => carDetails.fuelType;
  int get seatingCapacity => carDetails.seatingCapacity;
  double get avgRating => carDetails.avgRating;
  int get totalReviews => carDetails.totalReviews;
  String get ownerName => carDetails.ownerName;
  double get ownerRating => carDetails.ownerRating;
  
  // Platform policies getters
  String get cancellationPolicy => platformPolicies.cancellationPolicy;
  String get insurancePolicy => platformPolicies.insurancePolicy;
  String get fuelPolicy => platformPolicies.fuelPolicy;
  String get lateReturnPolicy => platformPolicies.lateReturnPolicy;
  String get damagePolicy => platformPolicies.damagePolicy;
}

class CarDetails {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final String transmissionType;
  final String fuelType;
  final int seatingCapacity;
  final double avgRating;
  final int totalReviews;
  final String ownerName;
  final double ownerRating;
  final List<CarImage> images;

  CarDetails({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.transmissionType,
    required this.fuelType,
    required this.seatingCapacity,
    required this.avgRating,
    required this.totalReviews,
    required this.ownerName,
    required this.ownerRating,
    required this.images,
  });

  factory CarDetails.fromJson(Map<String, dynamic> json) {
    return CarDetails(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      plateNumber: json['plate_number'],
      transmissionType: json['transmission_type'],
      fuelType: json['fuel_type'],
      seatingCapacity: json['seating_capacity'],
      avgRating: json['avg_rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      ownerName: json['owner_name'],
      ownerRating: json['owner_rating']?.toDouble() ?? 0.0,
      images: json['images'] != null 
          ? List<CarImage>.from(json['images'].map((x) => CarImage.fromJson(x)))
          : [],
    );
  }

  // Get the first image URL or return null if no images
  String? get firstImageUrl {
    if (images.isNotEmpty) {
      return images.first.url;
    }
    return null;
  }

  // Get the first image URL with proper encoding
  String? get firstImageUrlEncoded {
    if (images.isNotEmpty) {
      final url = images.first.url;
      // Fix URL encoding issues by replacing spaces and encoding properly
      return Uri.encodeFull(url.replaceAll(' ', ''));
    }
    return null;
  }
}

class CarImage {
  final int id;
  final String url;
  final String type;

  CarImage({
    required this.id,
    required this.url,
    required this.type,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: json['id'],
      url: json['url'],
      type: json['type'],
    );
  }
}

class RentalDetails {
  final String startDate;
  final String endDate;
  final int durationDays;
  final String pickupAddress;
  final String dropoffAddress;
  final String pickupLatitude;
  final String pickupLongitude;
  final String dropoffLatitude;
  final String dropoffLongitude;

  RentalDetails({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
  });

  factory RentalDetails.fromJson(Map<String, dynamic> json) {
    return RentalDetails(
      startDate: json['start_date'],
      endDate: json['end_date'],
      durationDays: json['duration_days'],
      pickupAddress: json['pickup_address'],
      dropoffAddress: json['dropoff_address'],
      pickupLatitude: json['pickup_latitude'],
      pickupLongitude: json['pickup_longitude'],
      dropoffLatitude: json['dropoff_latitude'],
      dropoffLongitude: json['dropoff_longitude'],
    );
  }
}

class Pricing {
  final double dailyPrice;
  final double baseCost;
  final double serviceFee;
  final int serviceFeePercentage;
  final double totalCost;
  final double depositAmount;
  final double remainingAmount;
  final int depositPercentage;

  Pricing({
    required this.dailyPrice,
    required this.baseCost,
    required this.serviceFee,
    required this.serviceFeePercentage,
    required this.totalCost,
    required this.depositAmount,
    required this.remainingAmount,
    required this.depositPercentage,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      dailyPrice: json['daily_price']?.toDouble() ?? 0.0,
      baseCost: json['base_cost']?.toDouble() ?? 0.0,
      serviceFee: json['service_fee']?.toDouble() ?? 0.0,
      serviceFeePercentage: json['service_fee_percentage'] ?? 0,
      totalCost: json['total_cost']?.toDouble() ?? 0.0,
      depositAmount: json['deposit_amount']?.toDouble() ?? 0.0,
      remainingAmount: json['remaining_amount']?.toDouble() ?? 0.0,
      depositPercentage: json['deposit_percentage'] ?? 0,
    );
  }
}

class UsagePolicy {
  final double dailyKmLimit;
  final double totalAllowedKm;
  final double extraKmCost;
  final int dailyHourLimit;
  final double extraHourCost;

  UsagePolicy({
    required this.dailyKmLimit,
    required this.totalAllowedKm,
    required this.extraKmCost,
    required this.dailyHourLimit,
    required this.extraHourCost,
  });

  factory UsagePolicy.fromJson(Map<String, dynamic> json) {
    return UsagePolicy(
      dailyKmLimit: json['daily_km_limit']?.toDouble() ?? 0.0,
      totalAllowedKm: json['total_allowed_km']?.toDouble() ?? 0.0,
      extraKmCost: json['extra_km_cost']?.toDouble() ?? 0.0,
      dailyHourLimit: json['daily_hour_limit'] ?? 0,
      extraHourCost: json['extra_hour_cost']?.toDouble() ?? 0.0,
    );
  }
}

class PaymentMethods {
  final String selectedMethod;
  final int selectedCardId;
  final List<String> availableMethods;

  PaymentMethods({
    required this.selectedMethod,
    required this.selectedCardId,
    required this.availableMethods,
  });

  factory PaymentMethods.fromJson(Map<String, dynamic> json) {
    return PaymentMethods(
      selectedMethod: json['selected_method'],
      selectedCardId: json['selected_card_id'],
      availableMethods: List<String>.from(json['available_methods']),
    );
  }
}

class PlatformPolicies {
  final String cancellationPolicy;
  final String insurancePolicy;
  final String fuelPolicy;
  final String lateReturnPolicy;
  final String damagePolicy;

  PlatformPolicies({
    required this.cancellationPolicy,
    required this.insurancePolicy,
    required this.fuelPolicy,
    required this.lateReturnPolicy,
    required this.damagePolicy,
  });

  factory PlatformPolicies.fromJson(Map<String, dynamic> json) {
    return PlatformPolicies(
      cancellationPolicy: json['cancellation_policy'],
      insurancePolicy: json['insurance_policy'],
      fuelPolicy: json['fuel_policy'],
      lateReturnPolicy: json['late_return_policy'],
      damagePolicy: json['damage_policy'],
    );
  }
} 