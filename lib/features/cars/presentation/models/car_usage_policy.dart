class CarUsagePolicy {
  final double dailyKmLimit;
  final double extraKmCost;
  final int? dailyHourLimit;
  final double? extraHourCost;

  CarUsagePolicy({
    required this.dailyKmLimit,
    required this.extraKmCost,
    this.dailyHourLimit,
    this.extraHourCost,
  });

  factory CarUsagePolicy.fromJson(Map<String, dynamic> json) {
    return CarUsagePolicy(
      dailyKmLimit: double.tryParse(json['daily_km_limit'].toString()) ?? 0,
      extraKmCost: double.tryParse(json['extra_km_cost'].toString()) ?? 0,
      dailyHourLimit: json['daily_hour_limit'] != null ? int.tryParse(json['daily_hour_limit'].toString()) : null,
      extraHourCost: json['extra_hour_cost'] != null ? double.tryParse(json['extra_hour_cost'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'daily_km_limit': dailyKmLimit,
    'extra_km_cost': extraKmCost,
    'daily_hour_limit': dailyHourLimit,
    'extra_hour_cost': extraHourCost,
  };

  CarUsagePolicy copyWith({
    double? dailyKmLimit,
    double? extraKmCost,
    int? dailyHourLimit,
    double? extraHourCost,
  }) {
    return CarUsagePolicy(
      dailyKmLimit: dailyKmLimit ?? this.dailyKmLimit,
      extraKmCost: extraKmCost ?? this.extraKmCost,
      dailyHourLimit: dailyHourLimit ?? this.dailyHourLimit,
      extraHourCost: extraHourCost ?? this.extraHourCost,
    );
  }
} 