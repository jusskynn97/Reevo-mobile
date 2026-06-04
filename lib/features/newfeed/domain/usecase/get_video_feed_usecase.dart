import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/domain/repository/video_repository.dart';

class GetVideoFeedUseCase {
  final VideoRepository repository;

  GetVideoFeedUseCase(this.repository);

  Future<Either<Failure, VideoFeedEntity>> call(GetVideoFeedParams params) async {
    return await repository.getVideoFeed(
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}

class GetVideoFeedParams extends Equatable {
  final String? cursor;
  final int limit;

  const GetVideoFeedParams({
    this.cursor,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [cursor, limit];
}
