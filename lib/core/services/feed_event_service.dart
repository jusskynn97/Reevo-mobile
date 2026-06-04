import 'package:dio/dio.dart';

class FeedEventService {
  final Dio dio;
  final String baseUrl;

  FeedEventService({
    required this.dio,
    required this.baseUrl,
  });

  Future<void> sendImpression(String videoId) async {
    await dio.post(
      '$baseUrl/api/feed/events/impression',
      data: {'videoId': videoId},
    );
  }

  Future<void> sendWatch(String videoId, int watchMs) async {
    if (watchMs <= 0) {
      return;
    }
    await dio.post(
      '$baseUrl/api/feed/events/watch',
      data: {'videoId': videoId, 'watchMs': watchMs},
    );
  }
}

