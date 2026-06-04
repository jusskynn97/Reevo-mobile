
class VideoSyncEventEntity {
  final String type;
  final int position;
  final bool? playing;
  final int? timestamp;
  final String? userId;
  final String? username;

  VideoSyncEventEntity({
    required this.type,
    required this.position,
    this.playing,
    this.timestamp,
    this.userId,
    this.username,
  });
}

