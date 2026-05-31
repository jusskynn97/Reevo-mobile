import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.metadata,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [id, userId, type, title, message, metadata, isRead, createdAt, readAt];
}
