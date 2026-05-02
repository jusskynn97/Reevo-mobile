import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/newfeed/data/datasource/video_remote_datasource.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/domain/repository/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VideoFeedEntity>> getVideoFeed({
    required String? cursor,
    required int limit,
  }) async {
    try {
      final result = await remoteDataSource.getVideoFeed(
        cursor: cursor,
        limit: limit,
      );

      if (result.success) {
        return Right(result.data.toEntity());
      } else {
        return Left(
          ServerFailure(message: result.message),
        );
      }
    } on Exception catch (e) {
      return Left(
        ServerFailure(message: e.toString()),
      );
    }
  }
}
