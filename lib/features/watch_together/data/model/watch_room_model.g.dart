// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchRoomModel _$WatchRoomModelFromJson(Map<String, dynamic> json) =>
    WatchRoomModel(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      videoId: json['videoId'] as String?,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      privacy: json['privacy'] as String,
      isActive: json['isActive'] as bool,
      maxUsers: (json['maxUsers'] as num).toInt(),
      participantCount: (json['participantCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WatchRoomModelToJson(WatchRoomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'name': instance.name,
      'description': instance.description,
      'videoId': instance.videoId,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'privacy': instance.privacy,
      'isActive': instance.isActive,
      'maxUsers': instance.maxUsers,
      'participantCount': instance.participantCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
