import 'package:equatable/equatable.dart';

abstract class InteractionEvent extends Equatable {
  const InteractionEvent();

  @override
  List<Object?> get props => [];
}

class LikeVideoEvent extends InteractionEvent {
  final String videoId;
  const LikeVideoEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class UnlikeVideoEvent extends InteractionEvent {
  final String videoId;
  const UnlikeVideoEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class CommentVideoEvent extends InteractionEvent {
  final String videoId;
  final String content;
  final String? parentId;
  const CommentVideoEvent({
    required this.videoId,
    required this.content,
    this.parentId,
  });

  @override
  List<Object?> get props => [videoId, content, parentId];
}

class GetCommentsEvent extends InteractionEvent {
  final String videoId;
  const GetCommentsEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class LikeCommentEvent extends InteractionEvent {
  final String commentId;
  const LikeCommentEvent(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class UnlikeCommentEvent extends InteractionEvent {
  final String commentId;
  const UnlikeCommentEvent(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class GetRepliesEvent extends InteractionEvent {
  final String commentId;
  const GetRepliesEvent(this.commentId);

  @override
  List<Object?> get props => [commentId];
}
