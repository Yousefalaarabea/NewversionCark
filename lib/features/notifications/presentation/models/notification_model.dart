// models/notification_model.dart
class NotificationModel {
  final String id;
  final int? sender;
  final String? senderEmail;
  final int receiver;
  final String receiverEmail;
  final String title;
  final String message;
  final String notificationType;
  final String typeDisplay;
  final String priority;
  final String priorityDisplay;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    this.sender,
    this.senderEmail,
    required this.receiver,
    required this.receiverEmail,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.typeDisplay,
    required this.priority,
    required this.priorityDisplay,
    required this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      sender: json['sender'],
      senderEmail: json['sender_email'],
      receiver: json['receiver'],
      receiverEmail: json['receiver_email'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      typeDisplay: json['type_display'],
      priority: json['priority'],
      priorityDisplay: json['priority_display'],
      data: json['data'] ?? {},
      isRead: json['is_read'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      timeAgo: json['time_ago'],
    );
  }
}

class NotificationResponse {
  final List<NotificationModel> results;
  final int totalCount;
  final int unreadCount;
  final int readCount;
  final NotificationStats stats;

  NotificationResponse({
    required this.results,
    required this.totalCount,
    required this.unreadCount,
    required this.readCount,
    required this.stats,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      results: (json['results'] as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      totalCount: json['total_count'],
      unreadCount: json['unread_count'],
      readCount: json['read_count'],
      stats: NotificationStats.fromJson(json['stats']),
    );
  }
}

class NotificationStats {
  final Map<String, int> byType;
  final Map<String, int> byPriority;

  NotificationStats({
    required this.byType,
    required this.byPriority,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      byType: Map<String, int>.from(json['by_type']),
      byPriority: Map<String, int>.from(json['by_priority']),
    );
  }
}