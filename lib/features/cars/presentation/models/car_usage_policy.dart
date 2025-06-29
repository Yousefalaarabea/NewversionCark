class CarUsagePolicy {
  final int dailyKmLimit;
  final double extraKmCost;
  final int dailyHourLimit;
  final double extraHourCost;

  CarUsagePolicy({
    required this.dailyKmLimit,
    required this.extraKmCost,
    required this.dailyHourLimit,
    required this.extraHourCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_km_limit': dailyKmLimit,
      'extra_km_cost': extraKmCost,
      'daily_hour_limit': dailyHourLimit,
      'extra_hour_cost': extraHourCost,
    };
  }

  factory CarUsagePolicy.fromJson(Map<String, dynamic> json) {
    return CarUsagePolicy(
      dailyKmLimit: json['daily_km_limit'] as int,
      extraKmCost: json['extra_km_cost'] as double,
      dailyHourLimit: json['daily_hour_limit'] as int,
      extraHourCost: json['extra_hour_cost'] as double,
    );
  }

  CarUsagePolicy copyWith({
    int? dailyKmLimit,
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