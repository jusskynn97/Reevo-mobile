
class RoomMessageEntity {
  final String id;
  final String senderId;
  final String senderUsername;
  final String? senderAvatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  RoomMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderAvatarUrl,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });
}

