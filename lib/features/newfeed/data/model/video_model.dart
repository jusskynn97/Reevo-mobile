import 'package:json_annotation/json_annotation.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
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

  VideoModel({
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

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  VideoEntity toEntity() {
    return VideoEntity(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      description: description,
      uploaderName: uploaderName,
      uploaderAvatar: uploaderAvatar,
      uploaderId: uploaderId,
      duration: duration,
      uploadedAt: uploadedAt,
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
