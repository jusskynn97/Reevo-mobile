import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_bloc.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_event.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_state.dart';
import 'package:reevo/features/interaction/domain/entity/comment_entity.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String videoId;
  const CommentsBottomSheet({super.key, required this.videoId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  CommentEntity? _replyingToComment;

  @override
  void initState() {
    super.initState();
    context.read<InteractionBloc>().add(GetCommentsEvent(widget.videoId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      context.read<InteractionBloc>().add(CommentVideoEvent(
            videoId: widget.videoId,
            content: content,
            parentId: _replyingToComment?.id,
          ));
      _commentController.clear();
      setState(() {
        _replyingToComment = null;
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _onReply(CommentEntity comment) {
    setState(() {
      _replyingToComment = comment;
    });
    FocusScope.of(context).requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                BlocBuilder<InteractionBloc, InteractionState>(
                  builder: (context, state) {
                    return Text(
                      '${state.comments.length} Comments',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.grey5,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.grey5, height: 1),

          // Comments List
          Expanded(
            child: BlocBuilder<InteractionBloc, InteractionState>(
              builder: (context, state) {
                if (state.fetchStatus == InteractionStatus.loading && state.comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.brand));
                }
                if (state.fetchStatus == InteractionStatus.failure && state.comments.isEmpty) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'Failed to load comments',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (state.comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(color: AppColors.grey3),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentWithReplies(state.comments[index], state);
                  },
                );
              },
            ),
          ),

          // Replying Indicator
          if (_replyingToComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.grey5.withOpacity(0.5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to @${_replyingToComment!.username}',
                      style: const TextStyle(color: AppColors.grey3, fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingToComment = null),
                    child: const Icon(Icons.close, color: AppColors.grey3, size: 16),
                  ),
                ],
              ),
            ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.grey5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey5,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _replyingToComment != null 
                            ? 'Reply to @${_replyingToComment!.username}...' 
                            : 'Add a comment...',
                        hintStyle: const TextStyle(color: AppColors.grey3),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                BlocBuilder<InteractionBloc, InteractionState>(
                  builder: (context, state) {
                    if (state.commentStatus == InteractionStatus.loading) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brand,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: _sendComment,
                      child: const Icon(Icons.send, color: AppColors.brand),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentWithReplies(CommentEntity comment, InteractionState state) {
    final replies = state.replies[comment.id] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(comment),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 44.0),
            child: Column(
              children: replies.map((reply) => _buildCommentItem(reply, isReply: true)).toList(),
            ),
          ),
        // "View replies" button if any (mocking for now, but BLoC handles fetching)
        if (replies.isEmpty) // You could add a button to load replies if count > 0
          Padding(
            padding: const EdgeInsets.only(left: 44.0, bottom: 12.0),
            child: GestureDetector(
              onTap: () => context.read<InteractionBloc>().add(GetRepliesEvent(comment.id)),
              child: const Text(
                'View replies',
                style: TextStyle(color: AppColors.grey3, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentEntity comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isReply ? 12.0 : 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: AppColors.grey5,
            backgroundImage: (comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty)
                ? NetworkImage(comment.avatarUrl!) 
                : null,
            child: (comment.avatarUrl == null || comment.avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: Colors.white, size: isReply ? 16 : 20) 
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(
                    color: AppColors.grey3,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatDateTime(comment.createdAt),
                      style: const TextStyle(color: AppColors.grey3, fontSize: 12),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => _onReply(comment),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          color: AppColors.grey3,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (comment.isLiked) {
                    context.read<InteractionBloc>().add(UnlikeCommentEvent(comment.id));
                  } else {
                    context.read<InteractionBloc>().add(LikeCommentEvent(comment.id));
                  }
                },
                child: Icon(
                  comment.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: comment.isLiked ? Colors.red : AppColors.grey3,
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${comment.likeCount}',
                style: const TextStyle(color: AppColors.grey3, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'just now';
    }
  }
}
