// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomMessageModel _$RoomMessageModelFromJson(Map<String, dynamic> json) =>
    RoomMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderUsername: json['senderUsername'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RoomMessageModelToJson(RoomMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderUsername': instance.senderUsername,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };
