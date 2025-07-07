class ExcessChargesModel {
  final int agreedKilometers;
  final int actualKilometers;
  final int extraKilometers;
  final double extraKmRate;
  final double extraKmCost;
  
  final int agreedHours;
  final int actualHours;
  final int extraHours;
  final double extraHourRate;
  final double extraHourCost;
  
  final double totalExcessCost;

  ExcessChargesModel({
    required this.agreedKilometers,
    required this.actualKilometers,
    required this.extraKilometers,
    required this.extraKmRate,
    required this.extraKmCost,
    required this.agreedHours,
    required this.actualHours,
    required this.extraHours,
    required this.extraHourRate,
    required this.extraHourCost,
    required this.totalExcessCost,
  });

  // Mock data for testing
  // factory ExcessChargesModel.mock() {
  //   return ExcessChargesModel(
  //     agreedKilometers: 200,
  //     actualKilometers: 250,
  //     extraKilometers: 50,
  //     extraKmRate: 0.5,
  //     extraKmCost: 25.0,
  //     agreedHours: 24,
  //     actualHours: 28,
  //     extraHours: 4,
  //     extraHourRate: 10.0,
  //     extraHourCost: 40.0,
  //     totalExcessCost: 65.0,
  //   );
  // }

  // Calculate excess charges based on agreed and actual values
  factory ExcessChargesModel.calculate({
    required int agreedKilometers,
    required int actualKilometers,
    required double extraKmRate,
    required int agreedHours,
    required int actualHours,
    required double extraHourRate,
  }) {
    final extraKilometers = actualKilometers > agreedKilometers 
        ? actualKilometers - agreedKilometers 
        : 0;
    final extraKmCost = extraKilometers * extraKmRate;
    
    final extraHours = actualHours > agreedHours 
        ? actualHours - agreedHours 
        : 0;
    final extraHourCost = extraHours * extraHourRate;
    
    final totalExcessCost = extraKmCost + extraHourCost;
    
    return ExcessChargesModel(
      agreedKilometers: agreedKilometers,
      actualKilometers: actualKilometers,
      extraKilometers: extraKilometers,
      extraKmRate: extraKmRate,
      extraKmCost: extraKmCost,
      agreedHours: agreedHours,
      actualHours: actualHours,
      extraHours: extraHours,
      extraHourRate: extraHourRate,
      extraHourCost: extraHourCost,
      totalExcessCost: totalExcessCost,
    );
  }

  // Create a copy with updated fields
  ExcessChargesModel copyWith({
    int? agreedKilometers,
    int? actualKilometers,
    int? extraKilometers,
    double? extraKmRate,
    double? extraKmCost,
    int? agreedHours,
    int? actualHours,
    int? extraHours,
    double? extraHourRate,
    double? extraHourCost,
    double? totalExcessCost,
  }) {
    return ExcessChargesModel(
      agreedKilometers: agreedKilometers ?? this.agreedKilometers,
      actualKilometers: actualKilometers ?? this.actualKilometers,
      extraKilometers: extraKilometers ?? this.extraKilometers,
      extraKmRate: extraKmRate ?? this.extraKmRate,
      extraKmCost: extraKmCost ?? this.extraKmCost,
      agreedHours: agreedHours ?? this.agreedHours,
      actualHours: actualHours ?? this.actualHours,
      extraHours: extraHours ?? this.extraHours,
      extraHourRate: extraHourRate ?? this.extraHourRate,
      extraHourCost: extraHourCost ?? this.extraHourCost,
      totalExcessCost: totalExcessCost ?? this.totalExcessCost,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'agreedKilometers': agreedKilometers,
      'actualKilometers': actualKilometers,
      'extraKilometers': extraKilometers,
      'extraKmRate': extraKmRate,
      'extraKmCost': extraKmCost,
      'agreedHours': agreedHours,
      'actualHours': actualHours,
      'extraHours': extraHours,
      'extraHourRate': extraHourRate,
      'extraHourCost': extraHourCost,
      'totalExcessCost': totalExcessCost,
    };
  }

  // Create from JSON
  factory ExcessChargesModel.fromJson(Map<String, dynamic> json) {
    return ExcessChargesModel(
      agreedKilometers: json['agreedKilometers'],
      actualKilometers: json['actualKilometers'],
      extraKilometers: json['extraKilometers'],
      extraKmRate: json['extraKmRate'].toDouble(),
      extraKmCost: json['extraKmCost'].toDouble(),
      agreedHours: json['agreedHours'],
      actualHours: json['actualHours'],
      extraHours: json['extraHours'],
      extraHourRate: json['extraHourRate'].toDouble(),
      extraHourCost: json['extraHourCost'].toDouble(),
      totalExcessCost: json['totalExcessCost'].toDouble(),
    );
  }
} 