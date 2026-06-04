import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';
import 'package:reevo/features/interaction/domain/usecase/interaction_usecases.dart';
import 'interaction_event.dart';
import 'interaction_state.dart';

class InteractionBloc extends Bloc<InteractionEvent, InteractionState> {
  final LikeVideoUseCase likeVideoUseCase;
  final UnlikeVideoUseCase unlikeVideoUseCase;
  final CommentVideoUseCase commentVideoUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final UnlikeCommentUseCase unlikeCommentUseCase;
  final GetRepliesUseCase getRepliesUseCase;

  InteractionBloc({
    required this.likeVideoUseCase,
    required this.unlikeVideoUseCase,
    required this.commentVideoUseCase,
    required this.getCommentsUseCase,
    required this.likeCommentUseCase,
    required this.unlikeCommentUseCase,
    required this.getRepliesUseCase,
  }) : super(const InteractionState()) {
    on<LikeVideoEvent>(_onLikeVideo);
    on<UnlikeVideoEvent>(_onUnlikeVideo);
    on<CommentVideoEvent>(_onCommentVideo);
    on<GetCommentsEvent>(_onGetComments);
    on<LikeCommentEvent>(_onLikeComment);
    on<UnlikeCommentEvent>(_onUnlikeComment);
    on<GetRepliesEvent>(_onGetReplies);
  }

  Future<void> _onLikeVideo(
    LikeVideoEvent event,
    Emitter<InteractionState> emit,
  ) async {
    emit(state.copyWith(
      likeStatus: InteractionStatus.loading,
      lastActionVideoId: event.videoId,
    ));
    final result = await likeVideoUseCase(event.videoId);
    result.fold(
      (failure) => emit(state.copyWith(
        likeStatus: InteractionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(likeStatus: InteractionStatus.success)),
    );
  }

  Future<void> _onUnlikeVideo(
    UnlikeVideoEvent event,
    Emitter<InteractionState> emit,
  ) async {
    emit(state.copyWith(
      likeStatus: InteractionStatus.loading,
      lastActionVideoId: event.videoId,
    ));
    final result = await unlikeVideoUseCase(event.videoId);
    result.fold(
      (failure) => emit(state.copyWith(
        likeStatus: InteractionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(likeStatus: InteractionStatus.success)),
    );
  }

  Future<void> _onCommentVideo(
    CommentVideoEvent event,
    Emitter<InteractionState> emit,
  ) async {
    emit(state.copyWith(
      commentStatus: InteractionStatus.loading,
      lastActionVideoId: event.videoId,
    ));
    final result = await commentVideoUseCase(
      videoId: event.videoId,
      content: event.content,
      parentId: event.parentId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        commentStatus: InteractionStatus.failure,
        errorMessage: failure.message,
      )),
      (comment) {
        if (event.parentId == null) {
          emit(state.copyWith(
            commentStatus: InteractionStatus.success,
            comments: [comment, ...state.comments],
          ));
        } else {
          final updatedReplies = Map<String, List<CommentEntity>>.from(state.replies);
          final currentReplies = updatedReplies[event.parentId] ?? [];
          updatedReplies[event.parentId!] = [...currentReplies, comment];
          emit(state.copyWith(
            commentStatus: InteractionStatus.success,
            replies: updatedReplies,
          ));
        }
      },
    );
  }

  Future<void> _onGetComments(
    GetCommentsEvent event,
    Emitter<InteractionState> emit,
  ) async {
    emit(state.copyWith(
      fetchStatus: InteractionStatus.loading,
      commentStatus: InteractionStatus.initial,
      likeStatus: InteractionStatus.initial,
      comments: [], // Clear comments for new video
      errorMessage: null,
    ));
    final result = await getCommentsUseCase(event.videoId);
    result.fold(
      (failure) => emit(state.copyWith(
        fetchStatus: InteractionStatus.failure,
        errorMessage: failure.message,
      )),
      (comments) => emit(state.copyWith(
        fetchStatus: InteractionStatus.success,
        comments: comments,
      )),
    );
  }

  Future<void> _onLikeComment(
    LikeCommentEvent event,
    Emitter<InteractionState> emit,
  ) async {
    final result = await likeCommentUseCase(event.commentId);
    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (_) {
        // Update top-level comments
        final updatedComments = state.comments.map((c) {
          if (c.id == event.commentId) {
            return _updateCommentLike(c, true);
          }
          return c;
        }).toList();

        // Update replies
        final updatedReplies = Map<String, List<CommentEntity>>.from(state.replies);
        updatedReplies.forEach((key, list) {
          updatedReplies[key] = list.map((c) {
            if (c.id == event.commentId) {
              return _updateCommentLike(c, true);
            }
            return c;
          }).toList();
        });

        emit(state.copyWith(
          comments: updatedComments,
          replies: updatedReplies,
        ));
      },
    );
  }

  Future<void> _onUnlikeComment(
    UnlikeCommentEvent event,
    Emitter<InteractionState> emit,
  ) async {
    final result = await unlikeCommentUseCase(event.commentId);
    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (_) {
        // Update top-level comments
        final updatedComments = state.comments.map((c) {
          if (c.id == event.commentId) {
            return _updateCommentLike(c, false);
          }
          return c;
        }).toList();

        // Update replies
        final updatedReplies = Map<String, List<CommentEntity>>.from(state.replies);
        updatedReplies.forEach((key, list) {
          updatedReplies[key] = list.map((c) {
            if (c.id == event.commentId) {
              return _updateCommentLike(c, false);
            }
            return c;
          }).toList();
        });

        emit(state.copyWith(
          comments: updatedComments,
          replies: updatedReplies,
        ));
      },
    );
  }

  CommentEntity _updateCommentLike(CommentEntity comment, bool isLike) {
    return CommentEntity(
      id: comment.id,
      videoId: comment.videoId,
      userId: comment.userId,
      username: comment.username,
      avatarUrl: comment.avatarUrl,
      content: comment.content,
      parentId: comment.parentId,
      createdAt: comment.createdAt,
      likeCount: isLike ? comment.likeCount + 1 : comment.likeCount - 1,
      isLiked: isLike,
    );
  }

  Future<void> _onGetReplies(
    GetRepliesEvent event,
    Emitter<InteractionState> emit,
  ) async {
    final result = await getRepliesUseCase(event.commentId);
    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (replies) {
        final updatedReplies = Map<String, List<CommentEntity>>.from(state.replies);
        updatedReplies[event.commentId] = replies;
        emit(state.copyWith(
          replies: updatedReplies,
        ));
      },
    );
  }
}
