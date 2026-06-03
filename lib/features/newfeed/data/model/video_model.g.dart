// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
  id: json['id'] as String?,
  videoUrl: json['videoUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  description: json['description'] as String?,
  uploaderName: json['uploaderName'] as String?,
  uploaderAvatar: json['uploaderAvatar'] as String?,
  uploaderId: json['uploaderId'] as String?,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  uploadedAt: json['uploadedAt'] == null
      ? null
      : DateTime.parse(json['uploadedAt'] as String),
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'description': instance.description,
      'uploaderName': instance.uploaderName,
      'uploaderAvatar': instance.uploaderAvatar,
      'uploaderId': instance.uploaderId,
      'duration': instance.duration,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'isLiked': instance.isLiked,
    };

VideoFeedModel _$VideoFeedModelFromJson(Map<String, dynamic> json) =>
    VideoFeedModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$VideoFeedModelToJson(VideoFeedModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };

VideoFeedResponseModel _$VideoFeedResponseModelFromJson(
  Map<String, dynamic> json,
) => VideoFeedResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: VideoFeedModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VideoFeedResponseModelToJson(
  VideoFeedResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
