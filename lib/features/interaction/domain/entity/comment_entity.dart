import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String videoId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  const CommentEntity({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.likeCount,
    this.isLiked = false,
  });

  @override
  List<Object?> get props => [
        id,
        videoId,
        userId,
        username,
        avatarUrl,
        content,
        parentId,
        createdAt,
        likeCount,
        isLiked,
      ];
}
