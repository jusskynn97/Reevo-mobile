import 'package:json_annotation/json_annotation.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  final String videoId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  CommentModel({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.likeCount,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      videoId: videoId,
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      content: content,
      parentId: parentId,
      createdAt: createdAt,
      likeCount: likeCount,
      isLiked: isLiked,
    );
  }
}

@JsonSerializable()
class CommentResponseModel {
  final bool success;
  final String message;
  final CommentModel? data;

  CommentResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory CommentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentResponseModelToJson(this);
}

@JsonSerializable()
class CommentListResponseModel {
  final bool success;
  final String message;
  final List<CommentModel> data;

  CommentListResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommentListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommentListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentListResponseModelToJson(this);
}

@JsonSerializable()
class InteractionActionResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  InteractionActionResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory InteractionActionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$InteractionActionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionActionResponseModelToJson(this);
}
