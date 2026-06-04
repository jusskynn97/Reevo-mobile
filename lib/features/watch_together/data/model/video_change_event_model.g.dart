// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_change_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoChangeEventModel _$VideoChangeEventModelFromJson(
  Map<String, dynamic> json,
) => VideoChangeEventModel(
  videoId: json['videoId'] as String,
  videoUrl: json['videoUrl'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  timestamp: (json['timestamp'] as num).toInt(),
  userId: json['userId'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$VideoChangeEventModelToJson(
  VideoChangeEventModel instance,
) => <String, dynamic>{
  'videoId': instance.videoId,
  'videoUrl': instance.videoUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'timestamp': instance.timestamp,
  'userId': instance.userId,
  'username': instance.username,
};
