
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/video_sync_event_entity.dart';

part 'video_sync_event_model.g.dart';

@JsonSerializable(includeIfNull: false)
class VideoSyncEventModel extends VideoSyncEventEntity {
  VideoSyncEventModel({
    required super.type,
    required super.position,
    super.playing,
    super.timestamp,
    super.userId,
    super.username,
  });

  factory VideoSyncEventModel.fromJson(Map<String, dynamic> json) =>
      _$VideoSyncEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSyncEventModelToJson(this);
}

