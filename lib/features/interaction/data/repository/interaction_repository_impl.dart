import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/interaction/data/datasource/interaction_remote_datasource.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';
import 'package:reevo/features/interaction/domain/repository/interaction_repository.dart';

class InteractionRepositoryImpl implements InteractionRepository {
  final InteractionRemoteDataSource remoteDataSource;

  InteractionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> likeVideo(String videoId) async {
    try {
      final result = await remoteDataSource.likeVideo(videoId);
      if (result.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeVideo(String videoId) async {
    try {
      final result = await remoteDataSource.unlikeVideo(videoId);
      if (result.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> commentVideo({
    required String videoId,
    required String content,
    String? parentId,
  }) async {
    try {
      final result = await remoteDataSource.commentVideo(
        videoId: videoId,
        content: content,
        parentId: parentId,
      );
      if (result.success && result.data != null) {
        return Right(result.data!.toEntity());
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(String videoId) async {
    try {
      final result = await remoteDataSource.getComments(videoId);
      if (result.success) {
        return Right(result.data.map((model) => model.toEntity()).toList());
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likeComment(String commentId) async {
    try {
      final result = await remoteDataSource.likeComment(commentId);
      if (result.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeComment(String commentId) async {
    try {
      final result = await remoteDataSource.unlikeComment(commentId);
      if (result.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getReplies(String commentId) async {
    try {
      final result = await remoteDataSource.getReplies(commentId);
      if (result.success) {
        return Right(result.data.map((model) => model.toEntity()).toList());
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
