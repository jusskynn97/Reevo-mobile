import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final String uploaderName;
  final String? uploaderAvatar;
  final String uploaderId;
  final int duration;
  final DateTime uploadedAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const VideoEntity({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    required this.uploaderName,
    this.uploaderAvatar,
    required this.uploaderId,
    required this.duration,
    required this.uploadedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  VideoEntity copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? description,
    String? uploaderName,
    String? uploaderAvatar,
    String? uploaderId,
    int? duration,
    DateTime? uploadedAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return VideoEntity(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderAvatar: uploaderAvatar ?? this.uploaderAvatar,
      uploaderId: uploaderId ?? this.uploaderId,
      duration: duration ?? this.duration,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
    id,
    videoUrl,
    thumbnailUrl,
    description,
    uploaderName,
    uploaderAvatar,
    uploaderId,
    duration,
    uploadedAt,
    likeCount,
    commentCount,
    isLiked,
  ];
}

class VideoFeedEntity extends Equatable {
  final List<VideoEntity> items;
  final String? nextCursor;

  const VideoFeedEntity({
    required this.items,
    this.nextCursor,
  });

  @override
  List<Object?> get props => [items, nextCursor];
}
