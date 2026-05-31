import 'package:dio/dio.dart';
import 'package:reevo/features/newfeed/data/model/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<VideoFeedResponseModel> getVideoFeed({
    required String? cursor,
    required int limit,
  });
  Future<List<VideoModel>> getUserVideos({
    required String userId,
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
        'size': limit,
      };

      if (cursor != null) {
        queryParams['cursor'] = cursor;
      }

      final response = await dio.get(
        '$baseUrl/api/feed/videos',
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

  @override
  Future<List<VideoModel>> getUserVideos({
    required String userId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/videos/user/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['data'] as List<dynamic>;
        return items.map((item) => VideoModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch user videos');
      }
    } catch (e) {
      rethrow;
    }
  }
}
