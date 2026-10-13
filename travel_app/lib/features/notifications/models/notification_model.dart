import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'event', 'trip_reminder', 'group_update'
  final DateTime timestamp;
  final bool isRead;
  final String? travelId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.travelId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String documentId) {
    return NotificationModel(
      id: documentId,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'event',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      travelId: json['travelId'] ?? json['travel_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (travelId != null) 'travelId': travelId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? travelId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      travelId: travelId ?? this.travelId,
    );
  }
}
