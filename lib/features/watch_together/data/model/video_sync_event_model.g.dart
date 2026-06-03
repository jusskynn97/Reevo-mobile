// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_sync_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoSyncEventModel _$VideoSyncEventModelFromJson(Map<String, dynamic> json) =>
    VideoSyncEventModel(
      type: json['type'] as String,
      position: (json['position'] as num).toInt(),
      playing: json['playing'] as bool?,
      timestamp: (json['timestamp'] as num?)?.toInt(),
      userId: json['userId'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$VideoSyncEventModelToJson(
  VideoSyncEventModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'position': instance.position,
  'playing': ?instance.playing,
  'timestamp': ?instance.timestamp,
  'userId': ?instance.userId,
  'username': ?instance.username,
};
