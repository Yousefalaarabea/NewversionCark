class HandoverLogModel {
  final String id;
  final String handoverId;
  final String action; // 'renter_upload_car_image', 'renter_upload_odometer', 'renter_payment', 'renter_handover', 'owner_review', 'owner_handover'
  final String actor; // 'renter', 'owner'
  final String status; // 'pending', 'completed', 'failed'
  final String? description;
  final Map<String, dynamic>? metadata; // Additional data for the action
  final DateTime timestamp;
  final DateTime? completedAt;

  HandoverLogModel({
    required this.id,
    required this.handoverId,
    required this.action,
    required this.actor,
    required this.status,
    this.description,
    this.metadata,
    required this.timestamp,
    this.completedAt,
  });

  // Create a new log entry
  factory HandoverLogModel.create({
    required String handoverId,
    required String action,
    required String actor,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return HandoverLogModel(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      handoverId: handoverId,
      action: action,
      actor: actor,
      status: 'pending',
      description: description,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  // Mark log as completed
  HandoverLogModel markCompleted({String? description}) {
    return HandoverLogModel(
      id: id,
      handoverId: handoverId,
      action: action,
      actor: actor,
      status: 'completed',
      description: description ?? this.description,
      metadata: metadata,
      timestamp: timestamp,
      completedAt: DateTime.now(),
    );
  }

  // Mark log as failed
  HandoverLogModel markFailed({String? description}) {
    return HandoverLogModel(
      id: id,
      handoverId: handoverId,
      action: action,
      actor: actor,
      status: 'failed',
      description: description ?? this.description,
      metadata: metadata,
      timestamp: timestamp,
      completedAt: DateTime.now(),
    );
  }

  // Create a copy with updated fields
  HandoverLogModel copyWith({
    String? id,
    String? handoverId,
    String? action,
    String? actor,
    String? status,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    DateTime? completedAt,
  }) {
    return HandoverLogModel(
      id: id ?? this.id,
      handoverId: handoverId ?? this.handoverId,
      action: action ?? this.action,
      actor: actor ?? this.actor,
      status: status ?? this.status,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'handoverId': handoverId,
      'action': action,
      'actor': actor,
      'status': status,
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory HandoverLogModel.fromJson(Map<String, dynamic> json) {
    return HandoverLogModel(
      id: json['id'],
      handoverId: json['handoverId'],
      action: json['action'],
      actor: json['actor'],
      status: json['status'],
      description: json['description'],
      metadata: json['metadata'],
      timestamp: DateTime.parse(json['timestamp']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  // Static constants for actions
  static const String renterUploadCarImage = 'renter_upload_car_image';
  static const String renterUploadOdometer = 'renter_upload_odometer';
  static const String renterPayment = 'renter_payment';
  static const String renterHandover = 'renter_handover';
  static const String ownerReview = 'owner_review';
  static const String ownerHandover = 'owner_handover';

  // Static constants for actors
  static const String renter = 'renter';
  static const String owner = 'owner';

  // Static constants for status
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String failed = 'failed';
} 