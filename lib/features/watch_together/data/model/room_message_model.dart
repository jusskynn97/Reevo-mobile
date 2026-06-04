
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/room_message_entity.dart';

part 'room_message_model.g.dart';

@JsonSerializable()
class RoomMessageModel extends RoomMessageEntity {
  RoomMessageModel({
    required super.id,
    required super.senderId,
    required super.senderUsername,
    super.senderAvatarUrl,
    required super.content,
    super.imageUrl,
    required super.createdAt,
  });

  factory RoomMessageModel.fromJson(Map<String, dynamic> json) =>
      _$RoomMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomMessageModelToJson(this);
}

