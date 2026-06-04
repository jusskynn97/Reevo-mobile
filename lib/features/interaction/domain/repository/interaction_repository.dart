import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';

abstract class InteractionRepository {
  Future<Either<Failure, void>> likeVideo(String videoId);
  Future<Either<Failure, void>> unlikeVideo(String videoId);
  Future<Either<Failure, CommentEntity>> commentVideo({
    required String videoId,
    required String content,
    String? parentId,
  });
  Future<Either<Failure, List<CommentEntity>>> getComments(String videoId);
  Future<Either<Failure, void>> likeComment(String commentId);
  Future<Either<Failure, void>> unlikeComment(String commentId);
  Future<Either<Failure, List<CommentEntity>>> getReplies(String commentId);
}
