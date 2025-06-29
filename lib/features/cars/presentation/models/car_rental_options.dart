class CarRentalOptions {
  final bool availableWithoutDriver;
  final bool availableWithDriver;
  
  // Rental prices
  final double dailyRentalPrice;  // Mandatory field
  final double? monthlyRentalPrice;  // Calculated: dailyRentalPrice * 30 * 0.9 (10% discount)
  final double? yearlyRentalPrice;   // Calculated: monthlyRentalPrice * 12 * 0.9 (10% discount)

  CarRentalOptions({
    this.availableWithoutDriver = false,
    this.availableWithDriver = false,
    required this.dailyRentalPrice,
  }) : monthlyRentalPrice = dailyRentalPrice * 30 * 0.9,
       yearlyRentalPrice = dailyRentalPrice * 30 * 0.9 * 12 * 0.9;

  // Factory method to create a copy with updated values
  CarRentalOptions copyWith({
    bool? availableWithoutDriver,
    bool? availableWithDriver,
    double? dailyRentalPrice,
  }) {
    return CarRentalOptions(
      availableWithoutDriver: availableWithoutDriver ?? this.availableWithoutDriver,
      availableWithDriver: availableWithDriver ?? this.availableWithDriver,
      dailyRentalPrice: dailyRentalPrice ?? this.dailyRentalPrice,
    );
  }
} 