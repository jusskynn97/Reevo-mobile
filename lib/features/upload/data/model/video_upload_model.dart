import 'package:json_annotation/json_annotation.dart';
import 'package:reevo/features/upload/domain/entity/video_upload_entity.dart';

part 'video_upload_model.g.dart';

@JsonSerializable()
class VideoUploadDataModel {
  final String uploadId;
  final String message;
  final String status;

  VideoUploadDataModel({
    required this.uploadId,
    required this.message,
    required this.status,
  });

  factory VideoUploadDataModel.fromJson(Map<String, dynamic> json) =>
      _$VideoUploadDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoUploadDataModelToJson(this);

  VideoUploadEntity toEntity() {
    return VideoUploadEntity(
      uploadId: uploadId,
      message: message,
      status: status,
    );
  }
}

@JsonSerializable()
class VideoUploadResponseModel {
  final bool success;
  final String message;
  final VideoUploadDataModel data;

  VideoUploadResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VideoUploadResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VideoUploadResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoUploadResponseModelToJson(this);
}
