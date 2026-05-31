// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_upload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoUploadDataModel _$VideoUploadDataModelFromJson(
  Map<String, dynamic> json,
) => VideoUploadDataModel(
  uploadId: json['uploadId'] as String,
  message: json['message'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$VideoUploadDataModelToJson(
  VideoUploadDataModel instance,
) => <String, dynamic>{
  'uploadId': instance.uploadId,
  'message': instance.message,
  'status': instance.status,
};

VideoUploadResponseModel _$VideoUploadResponseModelFromJson(
  Map<String, dynamic> json,
) => VideoUploadResponseModel(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: VideoUploadDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VideoUploadResponseModelToJson(
  VideoUploadResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
