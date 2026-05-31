import 'package:equatable/equatable.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';

enum InteractionStatus { initial, loading, success, failure }

class InteractionState extends Equatable {
  final InteractionStatus fetchStatus;
  final InteractionStatus commentStatus;
  final InteractionStatus likeStatus;
  final List<CommentEntity> comments;
  final Map<String, List<CommentEntity>> replies; // commentId -> replies
  final String? lastActionVideoId;
  final String? errorMessage;

  const InteractionState({
    this.fetchStatus = InteractionStatus.initial,
    this.commentStatus = InteractionStatus.initial,
    this.likeStatus = InteractionStatus.initial,
    this.comments = const [],
    this.replies = const {},
    this.lastActionVideoId,
    this.errorMessage,
  });

  InteractionState copyWith({
    InteractionStatus? fetchStatus,
    InteractionStatus? commentStatus,
    InteractionStatus? likeStatus,
    List<CommentEntity>? comments,
    Map<String, List<CommentEntity>>? replies,
    String? lastActionVideoId,
    String? errorMessage,
  }) {
    return InteractionState(
      fetchStatus: fetchStatus ?? this.fetchStatus,
      commentStatus: commentStatus ?? this.commentStatus,
      likeStatus: likeStatus ?? this.likeStatus,
      comments: comments ?? this.comments,
      replies: replies ?? this.replies,
      lastActionVideoId: lastActionVideoId ?? this.lastActionVideoId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        fetchStatus,
        commentStatus,
        likeStatus,
        comments,
        replies,
        lastActionVideoId,
        errorMessage,
      ];
}
