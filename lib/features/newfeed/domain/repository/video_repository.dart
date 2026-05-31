import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';

abstract class VideoRepository {
  Future<Either<Failure, VideoFeedEntity>> getVideoFeed({
    required String? cursor,
    required int limit,
  });
  Future<Either<Failure, List<VideoEntity>>> getUserVideos({
    required String userId,
  });
}
