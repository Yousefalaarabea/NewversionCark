class CarModel {
  final String ownerId; // ForeignKey to User
  final int id;
  final String model;
  final String brand;
  final String carType; // choices: CAR_TYPE_CHOICES
  final String carCategory; // choices: CAR_CATEGORY_CHOICES
  final String plateNumber;
  final int year;
  final String color;
  final int seatingCapacity;
  final int luggageCapacity;
  final String transmissionType; // choices: TRANSMISSION_CHOICES
  final String fuelType; // choices: FUEL_CHOICES
  final int currentOdometerReading;
  final bool availability;
  final String currentStatus; // choices: STATUS_CHOICES
  final bool approvalStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RentalOptions rentalOptions;
  final String imageUrl;
  
  // Driver information fields
  final String? driverName;
  final double? driverRating;
  final int? driverTrips;
  final int? kmLimitPerDay;
  final double? waitingHourCost;
  final double? extraKmRate;

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
    this.luggageCapacity = 2, // Default value
    required this.transmissionType,
    required this.fuelType,
    required this.currentOdometerReading,
    required this.availability,
    required this.currentStatus,
    required this.approvalStatus,
    this.createdAt,
    this.updatedAt,
    required this.rentalOptions,
    this.imageUrl = 'https://cdn-icons-png.flaticon.com/512/743/743007.png',
    this.driverName,
    this.driverRating,
    this.driverTrips,
    this.kmLimitPerDay,
    this.waitingHourCost,
    this.extraKmRate,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      ownerId: json['ownerId'],
      id: json['id'],
      model: json['model'],
      brand: json['brand'],
      carType: json['car_type'],
      carCategory: json['car_category'],
      plateNumber: json['plate_number'],
      year: json['year'],
      color: json['color'],
      seatingCapacity: json['seating_capacity'],
      luggageCapacity: json['luggage_capacity'] ?? 2,
      transmissionType: json['transmission_type'],
      fuelType: json['fuel_type'],
      currentOdometerReading: json['current_odometer_reading'],
      availability: json['availability'],
      currentStatus: json['current_status'],
      approvalStatus: json['approval_status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      rentalOptions: RentalOptions.fromJson(json['rental_widgets'] ?? {}),
      imageUrl: json['image_url'] ?? 'https://cdn-icons-png.flaticon.com/512/743/743007.png',
      driverName: json['driver_name'],
      driverRating: json['driver_rating']?.toDouble(),
      driverTrips: json['driver_trips'],
      kmLimitPerDay: json['km_limit_per_day'],
      waitingHourCost: json['waiting_hour_cost']?.toDouble(),
      extraKmRate: json['extra_km_rate']?.toDouble(),
    );
  }

  CarModel copyWith({
    String? ownerId,
    int? id,
    String? model,
    String? brand,
    String? carType,
    String? carCategory,
    String? plateNumber,
    int? year,
    String? color,
    int? seatingCapacity,
    int? luggageCapacity,
    String? transmissionType,
    String? fuelType,
    int? currentOdometerReading,
    bool? availability,
    String? currentStatus,
    bool? approvalStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    RentalOptions? rentalOptions,
    String? imageUrl,
    String? driverName,
    double? driverRating,
    int? driverTrips,
    int? kmLimitPerDay,
    double? waitingHourCost,
    double? extraKmRate,
  }) {
    return CarModel(
      ownerId: ownerId ?? this.ownerId,
      id: id ?? this.id,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      carType: carType ?? this.carType,
      carCategory: carCategory ?? this.carCategory,
      plateNumber: plateNumber ?? this.plateNumber,
      year: year ?? this.year,
      color: color ?? this.color,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      currentOdometerReading: currentOdometerReading ?? this.currentOdometerReading,
      availability: availability ?? this.availability,
      currentStatus: currentStatus ?? this.currentStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rentalOptions: rentalOptions ?? this.rentalOptions,
      imageUrl: imageUrl ?? this.imageUrl,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      driverTrips: driverTrips ?? this.driverTrips,
      kmLimitPerDay: kmLimitPerDay ?? this.kmLimitPerDay,
      waitingHourCost: waitingHourCost ?? this.waitingHourCost,
      extraKmRate: extraKmRate ?? this.extraKmRate,
    );
  }

  factory CarModel.mock() {
    return CarModel(
      ownerId: 'owner_mock_id',
      id: 1,
      model: 'Accord',
      brand: 'Honda',
      carType: 'Sedan',
      carCategory: 'Standard',
      plateNumber: '123-ABC',
      year: 2023,
      color: 'Black',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Gasoline',
      currentOdometerReading: 15000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rentalOptions: RentalOptions.mock(),
      imageUrl: 'https://imgd.aeplcdn.com/1280x720/n/cw/ec/140945/camry-exterior-right-front-three-quarter-2.jpeg?is-cms=true&q=80',
      kmLimitPerDay: 450,
      extraKmRate: 0.60,
    );
  }
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
}
