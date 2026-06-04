// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  videoId: json['videoId'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  content: json['content'] as String,
  parentId: json['parentId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  likeCount: (json['likeCount'] as num).toInt(),
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoId': instance.videoId,
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'content': instance.content,
      'parentId': instance.parentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'likeCount': instance.likeCount,
      'isLiked': instance.isLiked,
    };

CommentResponseModel _$CommentResponseModelFromJson(
  Map<String, dynamic> json,
) => CommentResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CommentModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommentResponseModelToJson(
  CommentResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

CommentListResponseModel _$CommentListResponseModelFromJson(
  Map<String, dynamic> json,
) => CommentListResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CommentListResponseModelToJson(
  CommentListResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

InteractionActionResponseModel _$InteractionActionResponseModelFromJson(
  Map<String, dynamic> json,
) => InteractionActionResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$InteractionActionResponseModelToJson(
  InteractionActionResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
