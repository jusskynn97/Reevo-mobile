
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/watch_room_entity.dart';

part 'watch_room_model.g.dart';

@JsonSerializable()
class WatchRoomModel extends WatchRoomEntity {
  WatchRoomModel({
    required super.id,
    required super.creatorId,
    required super.name,
    super.description,
    super.videoId,
    super.videoUrl,
    super.thumbnailUrl,
    required super.privacy,
    required super.isActive,
    required super.maxUsers,
    required super.participantCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WatchRoomModel.fromJson(Map<String, dynamic> json) =>
      _$WatchRoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$WatchRoomModelToJson(this);
}

