class NewNotificationModel {
  List<Results>? results;
  int? totalCount;
  int? unreadCount;
  int? readCount;
  Stats? stats;

  NewNotificationModel(
      {this.results,
        this.totalCount,
        this.unreadCount,
        this.readCount,
        this.stats});

  NewNotificationModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
    totalCount = json['total_count'];
    unreadCount = json['unread_count'];
    readCount = json['read_count'];
    stats = json['stats'] != null ? new Stats.fromJson(json['stats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    data['total_count'] = this.totalCount;
    data['unread_count'] = this.unreadCount;
    data['read_count'] = this.readCount;
    if (this.stats != null) {
      data['stats'] = this.stats!.toJson();
    }
    return data;
  }
}

class Results {
  String? id;
  int? sender;
  String? senderEmail;
  int? receiver;
  String? receiverEmail;
  String? title;
  String? message;
  String? notificationType;
  String? typeDisplay;
  String? priority;
  String? priorityDisplay;
  Data? data;
  bool? isRead;
  String? createdAt;
  String? timeAgo;

  Results(
      {this.id,
        this.sender,
        this.senderEmail,
        this.receiver,
        this.receiverEmail,
        this.title,
        this.message,
        this.notificationType,
        this.typeDisplay,
        this.priority,
        this.priorityDisplay,
        this.data,
        this.isRead,
        this.createdAt,
        this.timeAgo});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sender = json['sender'];
    senderEmail = json['sender_email'];
    receiver = json['receiver'];
    receiverEmail = json['receiver_email'];
    title = json['title'];
    message = json['message'];
    notificationType = json['notification_type'];
    typeDisplay = json['type_display'];
    priority = json['priority'];
    priorityDisplay = json['priority_display'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    isRead = json['is_read'];
    createdAt = json['created_at'];
    timeAgo = json['time_ago'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sender'] = this.sender;
    data['sender_email'] = this.senderEmail;
    data['receiver'] = this.receiver;
    data['receiver_email'] = this.receiverEmail;
    data['title'] = this.title;
    data['message'] = this.message;
    data['notification_type'] = this.notificationType;
    data['type_display'] = this.typeDisplay;
    data['priority'] = this.priority;
    data['priority_display'] = this.priorityDisplay;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['is_read'] = this.isRead;
    data['created_at'] = this.createdAt;
    data['time_ago'] = this.timeAgo;
    return data;
  }
}

class Data {
  String? carName;
  String? pickupTime;
  int? rentalId;
  String? location;

  Data({this.carName, this.pickupTime, this.rentalId, this.location});

  Data.fromJson(Map<String, dynamic> json) {
    carName = json['car_name'];
    pickupTime = json['pickup_time'];
    rentalId = json['rental_id'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['car_name'] = this.carName;
    data['pickup_time'] = this.pickupTime;
    data['rental_id'] = this.rentalId;
    data['location'] = this.location;
    return data;
  }
}

class Stats {
  ByType? byType;
  ByPriority? byPriority;

  Stats({this.byType, this.byPriority});

  Stats.fromJson(Map<String, dynamic> json) {
    byType =
    json['by_type'] != null ? new ByType.fromJson(json['by_type']) : null;
    byPriority = json['by_priority'] != null
        ? new ByPriority.fromJson(json['by_priority'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.byType != null) {
      data['by_type'] = this.byType!.toJson();
    }
    if (this.byPriority != null) {
      data['by_priority'] = this.byPriority!.toJson();
    }
    return data;
  }
}

class ByType {
  int? rental;
  int? payment;
  int? system;
  int? promotion;
  int? other;

  ByType({this.rental, this.payment, this.system, this.promotion, this.other});

  ByType.fromJson(Map<String, dynamic> json) {
    rental = json['rental'];
    payment = json['payment'];
    system = json['system'];
    promotion = json['promotion'];
    other = json['other'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rental'] = this.rental;
    data['payment'] = this.payment;
    data['system'] = this.system;
    data['promotion'] = this.promotion;
    data['other'] = this.other;
    return data;
  }
}

class ByPriority {
  int? urgent;
  int? high;
  int? normal;
  int? low;

  ByPriority({this.urgent, this.high, this.normal, this.low});

  ByPriority.fromJson(Map<String, dynamic> json) {
    urgent = json['urgent'];
    high = json['high'];
    normal = json['normal'];
    low = json['low'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['urgent'] = this.urgent;
    data['high'] = this.high;
    data['normal'] = this.normal;
    data['low'] = this.low;
    return data;
  }
}