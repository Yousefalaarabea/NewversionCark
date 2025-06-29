class ContractModel {
  final String id;
  final String bookingId;
  final double depositAmount;
  final bool isDepositPaid;
  final String? contractImagePath;
  final bool isContractSigned;
  final bool isRemainingAmountReceived;
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime createdAt;

  ContractModel({
    required this.id,
    required this.bookingId,
    required this.depositAmount,
    required this.isDepositPaid,
    this.contractImagePath,
    this.isContractSigned = false,
    this.isRemainingAmountReceived = false,
    this.status = 'pending',
    required this.createdAt,
  });

  // Mock data for testing
  factory ContractModel.mock() {
    return ContractModel(
      id: 'contract_001',
      bookingId: 'booking_001',
      depositAmount: 500.0,
      isDepositPaid: true,
      createdAt: DateTime.now(),
    );
  }

  // Create a copy with updated fields
  ContractModel copyWith({
    String? id,
    String? bookingId,
    double? depositAmount,
    bool? isDepositPaid,
    String? contractImagePath,
    bool? isContractSigned,
    bool? isRemainingAmountReceived,
    String? status,
    DateTime? createdAt,
  }) {
    return ContractModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      depositAmount: depositAmount ?? this.depositAmount,
      isDepositPaid: isDepositPaid ?? this.isDepositPaid,
      contractImagePath: contractImagePath ?? this.contractImagePath,
      isContractSigned: isContractSigned ?? this.isContractSigned,
      isRemainingAmountReceived: isRemainingAmountReceived ?? this.isRemainingAmountReceived,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'depositAmount': depositAmount,
      'isDepositPaid': isDepositPaid,
      'contractImagePath': contractImagePath,
      'isContractSigned': isContractSigned,
      'isRemainingAmountReceived': isRemainingAmountReceived,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'],
      bookingId: json['bookingId'],
      depositAmount: json['depositAmount'].toDouble(),
      isDepositPaid: json['isDepositPaid'],
      contractImagePath: json['contractImagePath'],
      isContractSigned: json['isContractSigned'] ?? false,
      isRemainingAmountReceived: json['isRemainingAmountReceived'] ?? false,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 