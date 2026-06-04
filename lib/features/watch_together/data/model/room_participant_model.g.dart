// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_participant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomParticipantModel _$RoomParticipantModelFromJson(
  Map<String, dynamic> json,
) => RoomParticipantModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isMuted: json['isMuted'] as bool,
  isSpeaking: json['isSpeaking'] as bool,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  isHost: json['isHost'] as bool? ?? false,
);

Map<String, dynamic> _$RoomParticipantModelToJson(
  RoomParticipantModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'username': instance.username,
  'avatarUrl': instance.avatarUrl,
  'isMuted': instance.isMuted,
  'isSpeaking': instance.isSpeaking,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'isHost': instance.isHost,
};
