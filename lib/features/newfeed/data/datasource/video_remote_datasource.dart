import 'package:dio/dio.dart';
import 'package:reevo/features/newfeed/data/model/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<VideoFeedResponseModel> getVideoFeed({
    required String? cursor,
    required int limit,
  });
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  VideoRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<VideoFeedResponseModel> getVideoFeed({
    required String? cursor,
    required int limit,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
      };

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await dio.get(
        '$baseUrl/api/videos/feed',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return VideoFeedResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch video feed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
