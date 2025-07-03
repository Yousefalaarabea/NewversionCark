class CarRentalOptions {
  final bool availableWithoutDriver;
  final bool availableWithDriver;
  final double? dailyRentalPrice;
  final double? monthlyRentalPrice;
  final double? yearlyRentalPrice;
  final double? dailyRentalPriceWithDriver;
  final double? monthlyPriceWithDriver;
  final double? yearlyPriceWithDriver;

  CarRentalOptions({
    required this.availableWithoutDriver,
    required this.availableWithDriver,
    this.dailyRentalPrice,
    this.monthlyRentalPrice,
    this.yearlyRentalPrice,
    this.dailyRentalPriceWithDriver,
    this.monthlyPriceWithDriver,
    this.yearlyPriceWithDriver,
  });

  factory CarRentalOptions.fromJson(Map<String, dynamic> json) {
    return CarRentalOptions(
      availableWithoutDriver: json['available_without_driver'] ?? false,
      availableWithDriver: json['available_with_driver'] ?? false,
      dailyRentalPrice: json['daily_rental_price'] != null ? double.tryParse(json['daily_rental_price'].toString()) : null,
      monthlyRentalPrice: json['monthly_rental_price'] != null ? double.tryParse(json['monthly_rental_price'].toString()) : null,
      yearlyRentalPrice: json['yearly_rental_price'] != null ? double.tryParse(json['yearly_rental_price'].toString()) : null,
      dailyRentalPriceWithDriver: json['daily_rental_price_with_driver'] != null ? double.tryParse(json['daily_rental_price_with_driver'].toString()) : null,
      monthlyPriceWithDriver: json['monthly_price_with_driver'] != null ? double.tryParse(json['monthly_price_with_driver'].toString()) : null,
      yearlyPriceWithDriver: json['yearly_price_with_driver'] != null ? double.tryParse(json['yearly_price_with_driver'].toString()) : null,
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