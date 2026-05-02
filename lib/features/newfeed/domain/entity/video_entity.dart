import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String uploaderName;
  final String? uploaderAvatar;
  final String uploaderId;
  final int duration;
  final DateTime uploadedAt;

  const VideoEntity({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.uploaderName,
    this.uploaderAvatar,
    required this.uploaderId,
    required this.duration,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [
    id,
    videoUrl,
    thumbnailUrl,
    title,
    description,
    uploaderName,
    uploaderAvatar,
    uploaderId,
    duration,
    uploadedAt,
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
