
class WatchRoomEntity {
  final String id;
  final String creatorId;
  final String name;
  final String? description;
  final String? videoId;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String privacy;
  final bool isActive;
  final int maxUsers;
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  WatchRoomEntity({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    this.videoId,
    this.videoUrl,
    this.thumbnailUrl,
    required this.privacy,
    required this.isActive,
    required this.maxUsers,
    required this.participantCount,
    required this.createdAt,
    required this.updatedAt,
  });

  WatchRoomEntity copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    String? videoId,
    String? videoUrl,
    String? thumbnailUrl,
    String? privacy,
    bool? isActive,
    int? maxUsers,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WatchRoomEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      videoId: videoId ?? this.videoId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      privacy: privacy ?? this.privacy,
      isActive: isActive ?? this.isActive,
      maxUsers: maxUsers ?? this.maxUsers,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

