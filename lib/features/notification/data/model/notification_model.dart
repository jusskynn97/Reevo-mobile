import 'dart:convert';
import 'package:reevo/features/notification/domain/entity/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    super.metadata,
    required super.isRead,
    required super.createdAt,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? metadata;
    if (json['metadata'] != null) {
      try {
        if (json['metadata'] is String) {
          metadata = jsonDecode(json['metadata']);
        } else {
          metadata = json['metadata'];
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return NotificationModel(
      id: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      metadata: metadata,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : null,
    );
  }
}
