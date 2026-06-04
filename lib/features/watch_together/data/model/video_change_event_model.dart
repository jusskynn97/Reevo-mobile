
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/video_change_event_entity.dart';

part 'video_change_event_model.g.dart';

@JsonSerializable()
class VideoChangeEventModel extends Equatable implements VideoChangeEventEntity {
  @override
  final String videoId;

  @override
  final String videoUrl;

  @override
  final String? thumbnailUrl;

  @override
  final int timestamp;

  @override
  final String userId;

  @override
  final String username;

  const VideoChangeEventModel({
    required this.videoId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.timestamp,
    required this.userId,
    required this.username,
  });

  factory VideoChangeEventModel.fromJson(Map<String, dynamic> json) =>
      _$VideoChangeEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoChangeEventModelToJson(this);

  @override
  List<Object?> get props => [
        videoId,
        videoUrl,
        thumbnailUrl,
        timestamp,
        userId,
        username,
      ];
}
