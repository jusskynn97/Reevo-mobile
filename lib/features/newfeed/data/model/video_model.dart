import 'package:json_annotation/json_annotation.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  final String? id;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? description;
  final String? uploaderName;
  final String? uploaderAvatar;
  final String? uploaderId;
  final int duration;
  final DateTime? uploadedAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  VideoModel({
    this.id,
    this.videoUrl,
    this.thumbnailUrl,
    this.description,
    this.uploaderName,
    this.uploaderAvatar,
    this.uploaderId,
    this.duration = 0,
    this.uploadedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  VideoEntity toEntity() {
    return VideoEntity(
      id: id ?? '',
      videoUrl: videoUrl ?? '',
      thumbnailUrl: thumbnailUrl ?? '',
      description: description ?? '',
      uploaderName: uploaderName ?? '',
      uploaderAvatar: uploaderAvatar,
      uploaderId: uploaderId ?? '',
      duration: duration,
      uploadedAt: uploadedAt ?? DateTime.now(),
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLiked,
    );
  }
}

@JsonSerializable()
class VideoFeedModel {
  final List<VideoModel> items;
  @JsonKey(name: 'nextCursor')
  final String? nextCursor;

  VideoFeedModel({
    required this.items,
    this.nextCursor,
  });

  factory VideoFeedModel.fromJson(Map<String, dynamic> json) =>
      _$VideoFeedModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoFeedModelToJson(this);

  VideoFeedEntity toEntity() {
    return VideoFeedEntity(
      items: items.map((model) => model.toEntity()).toList(),
      nextCursor: nextCursor,
    );
  }
}

@JsonSerializable()
class VideoFeedResponseModel {
  final bool success;
  final String message;
  final VideoFeedModel data;

  VideoFeedResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VideoFeedResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VideoFeedResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoFeedResponseModelToJson(this);
}
