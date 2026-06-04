import 'package:dio/dio.dart';
import 'package:reevo/features/upload/data/model/video_upload_model.dart';

abstract class UploadRemoteDataSource {
  Future<VideoUploadResponseModel> uploadVideo({
    required String filePath,
    required String description,
    required String videoPrivacy,
    required DateTime? scheduleAt,
    required bool allowComment,
  });
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  UploadRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<VideoUploadResponseModel> uploadVideo({
    required String filePath,
    required String description,
    required String videoPrivacy,
    required DateTime? scheduleAt,
    required bool allowComment,
  }) async {
    try {
      // Build the multipart form data matching the backend VideoUploadRequest
      final formDataMap = <String, dynamic>{
        'description': description,
        'videoPrivacy': videoPrivacy,
        'allowComment': allowComment.toString(),
        'videoFile': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      };

      // Only include scheduleAt if it's not null
      if (scheduleAt != null) {
        formDataMap['scheduleAt'] = scheduleAt.toIso8601String();
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await dio.post(
        '$baseUrl/api/videos/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Increase timeouts for video upload
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (int sent, int total) {
          // Progress can be observed here if needed
          // final progress = sent / total;
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return VideoUploadResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to upload video: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
