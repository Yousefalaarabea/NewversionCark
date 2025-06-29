class RenterHandoverModel {
  final String? carImagePath;
  final int? odometerReading;
  final String? odometerImagePath;
  final bool isPaymentCompleted;
  final bool isContractConfirmed;

  RenterHandoverModel({
    this.carImagePath,
    this.odometerReading,
    this.odometerImagePath,
    this.isPaymentCompleted = false,
    this.isContractConfirmed = false,
  });

  RenterHandoverModel copyWith({
    String? carImagePath,
    int? odometerReading,
    String? odometerImagePath,
    bool? isPaymentCompleted,
    bool? isContractConfirmed,
  }) {
    return RenterHandoverModel(
      carImagePath: carImagePath ?? this.carImagePath,
      odometerReading: odometerReading ?? this.odometerReading,
      odometerImagePath: odometerImagePath ?? this.odometerImagePath,
      isPaymentCompleted: isPaymentCompleted ?? this.isPaymentCompleted,
      isContractConfirmed: isContractConfirmed ?? this.isContractConfirmed,
    );
  }
} 