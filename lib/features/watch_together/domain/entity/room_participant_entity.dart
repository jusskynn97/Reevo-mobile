
class RoomParticipantEntity {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final bool isMuted;
  final bool isSpeaking;
  final DateTime joinedAt;
  final bool isHost;

  RoomParticipantEntity({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.isMuted,
    required this.isSpeaking,
    required this.joinedAt,
    this.isHost = false,
  });
}

