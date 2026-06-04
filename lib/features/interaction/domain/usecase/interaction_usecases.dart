import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';
import 'package:reevo/features/interaction/domain/repository/interaction_repository.dart';

class LikeVideoUseCase {
  final InteractionRepository repository;
  LikeVideoUseCase(this.repository);

  Future<Either<Failure, void>> call(String videoId) {
    return repository.likeVideo(videoId);
  }
}

class UnlikeVideoUseCase {
  final InteractionRepository repository;
  UnlikeVideoUseCase(this.repository);

  Future<Either<Failure, void>> call(String videoId) {
    return repository.unlikeVideo(videoId);
  }
}

class CommentVideoUseCase {
  final InteractionRepository repository;
  CommentVideoUseCase(this.repository);

  Future<Either<Failure, CommentEntity>> call({
    required String videoId,
    required String content,
    String? parentId,
  }) {
    return repository.commentVideo(
      videoId: videoId,
      content: content,
      parentId: parentId,
    );
  }
}

class GetCommentsUseCase {
  final InteractionRepository repository;
  GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(String videoId) {
    return repository.getComments(videoId);
  }
}

class LikeCommentUseCase {
  final InteractionRepository repository;
  LikeCommentUseCase(this.repository);

  Future<Either<Failure, void>> call(String commentId) {
    return repository.likeComment(commentId);
  }
}

class UnlikeCommentUseCase {
  final InteractionRepository repository;
  UnlikeCommentUseCase(this.repository);

  Future<Either<Failure, void>> call(String commentId) {
    return repository.unlikeComment(commentId);
  }
}

class GetRepliesUseCase {
  final InteractionRepository repository;
  GetRepliesUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(String commentId) {
    return repository.getReplies(commentId);
  }
}
