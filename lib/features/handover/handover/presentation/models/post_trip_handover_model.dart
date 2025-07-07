import 'excess_charges_model.dart';

class PostTripHandoverModel {
  final String id;
  final String carId;
  final String ownerId;
  final String rentalId;
  
  // Car condition after trip
  final String? carImagePath;
  final String? odometerImagePath;
  final int? finalOdometerReading;
  
  // Excess charges
  final ExcessChargesModel? excessCharges;
  
  // Payment details
  final String paymentMethod; // 'visa', 'wallet', 'cash'
  final double? paymentAmount;
  final String? paymentStatus; // 'pending', 'completed', 'failed'
  
  // Notes
  final String? renterNotes;
  final String? ownerNotes;
  
  // Handover status
  final String renterHandoverStatus; // 'pending', 'completed'
  final String ownerHandoverStatus; // 'pending', 'completed'
  final DateTime? renterHandoverDate;
  final DateTime? ownerHandoverDate;
  
  // Trip status
  final String tripStatus; // 'active', 'completed', 'cancelled'
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  PostTripHandoverModel({
    required this.id,
    required this.carId,
    required this.ownerId,
    required this.rentalId,
    this.carImagePath,
    this.odometerImagePath,
    this.finalOdometerReading,
    this.excessCharges,
    required this.paymentMethod,
    this.paymentAmount,
    this.paymentStatus,
    this.renterNotes,
    this.ownerNotes,
    this.renterHandoverStatus = 'pending',
    this.ownerHandoverStatus = 'pending',
    this.renterHandoverDate,
    this.ownerHandoverDate,
    this.tripStatus = 'active',
    required this.createdAt,
    this.updatedAt,
  });

  // Mock data for testing
  factory PostTripHandoverModel.mock() {
    return PostTripHandoverModel(
      id: 'handover_${DateTime.now().millisecondsSinceEpoch}',
      carId: 'car_001',
      ownerId: 'owner_001',
      rentalId: 'rental_001',
      paymentMethod: 'visa',
      createdAt: DateTime.now(),
    );
  }

  // Create a copy with updated fields
  PostTripHandoverModel copyWith({
    String? id,
    String? carId,
    String? ownerId,
    String? rentalId,
    String? carImagePath,
    String? odometerImagePath,
    int? finalOdometerReading,
    ExcessChargesModel? excessCharges,
    String? paymentMethod,
    double? paymentAmount,
    String? paymentStatus,
    String? renterNotes,
    String? ownerNotes,
    String? renterHandoverStatus,
    String? ownerHandoverStatus,
    DateTime? renterHandoverDate,
    DateTime? ownerHandoverDate,
    String? tripStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostTripHandoverModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      ownerId: ownerId ?? this.ownerId,
      rentalId: rentalId ?? this.rentalId,
      carImagePath: carImagePath ?? this.carImagePath,
      odometerImagePath: odometerImagePath ?? this.odometerImagePath,
      finalOdometerReading: finalOdometerReading ?? this.finalOdometerReading,
      excessCharges: excessCharges ?? this.excessCharges,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      renterNotes: renterNotes ?? this.renterNotes,
      ownerNotes: ownerNotes ?? this.ownerNotes,
      renterHandoverStatus: renterHandoverStatus ?? this.renterHandoverStatus,
      ownerHandoverStatus: ownerHandoverStatus ?? this.ownerHandoverStatus,
      renterHandoverDate: renterHandoverDate ?? this.renterHandoverDate,
      ownerHandoverDate: ownerHandoverDate ?? this.ownerHandoverDate,
      tripStatus: tripStatus ?? this.tripStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'ownerId': ownerId,
      'rentalId': rentalId,
      'carImagePath': carImagePath,
      'odometerImagePath': odometerImagePath,
      'finalOdometerReading': finalOdometerReading,
      'excessCharges': excessCharges?.toJson(),
      'paymentMethod': paymentMethod,
      'paymentAmount': paymentAmount,
      'paymentStatus': paymentStatus,
      'renterNotes': renterNotes,
      'ownerNotes': ownerNotes,
      'renterHandoverStatus': renterHandoverStatus,
      'ownerHandoverStatus': ownerHandoverStatus,
      'renterHandoverDate': renterHandoverDate?.toIso8601String(),
      'ownerHandoverDate': ownerHandoverDate?.toIso8601String(),
      'tripStatus': tripStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory PostTripHandoverModel.fromJson(Map<String, dynamic> json) {
    return PostTripHandoverModel(
      id: json['id'],
      carId: json['carId'].toString(),
      ownerId: json['ownerId'].toString(),
      rentalId: json['rentalId'] != null ? json['rentalId'].toString() : '',
      carImagePath: json['carImagePath'],
      odometerImagePath: json['odometerImagePath'],
      finalOdometerReading: json['finalOdometerReading'],
      excessCharges: json['excessCharges'] != null 
          ? ExcessChargesModel.fromJson(json['excessCharges']) 
          : null,
      paymentMethod: json['paymentMethod'],
      paymentAmount: json['paymentAmount']?.toDouble(),
      paymentStatus: json['paymentStatus'],
      renterNotes: json['renterNotes'],
      ownerNotes: json['ownerNotes'],
      renterHandoverStatus: json['renterHandoverStatus'] ?? 'pending',
      ownerHandoverStatus: json['ownerHandoverStatus'] ?? 'pending',
      renterHandoverDate: json['renterHandoverDate'] != null 
          ? DateTime.parse(json['renterHandoverDate']) 
          : null,
      ownerHandoverDate: json['ownerHandoverDate'] != null 
          ? DateTime.parse(json['ownerHandoverDate']) 
          : null,
      tripStatus: json['tripStatus'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
} 