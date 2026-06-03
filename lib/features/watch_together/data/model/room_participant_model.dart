
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/room_participant_entity.dart';

part 'room_participant_model.g.dart';

@JsonSerializable()
class RoomParticipantModel extends RoomParticipantEntity {
  RoomParticipantModel({
    required super.id,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.isMuted,
    required super.isSpeaking,
    required super.joinedAt,
    super.isHost = false,
  });

  factory RoomParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$RoomParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomParticipantModelToJson(this);
}

