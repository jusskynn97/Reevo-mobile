import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/feed_event_service.dart';
import 'package:reevo/core/services/websocket_service.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/presentation/widgets/optimized_video_player.dart';
import 'package:reevo/features/newfeed/presentation/widgets/like_animation.dart';
import 'package:reevo/features/newfeed/presentation/widgets/comments_bottom_sheet.dart';
import 'package:reevo/features/newfeed/presentation/widgets/animated_count.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_bloc.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_event.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_state.dart';

class FeedItemOptimized extends StatefulWidget {
  final VideoEntity video;
  final bool isVisible;
  final ValueChanged<bool>? onPlayStateChanged;
  final ValueChanged<Duration>? onPositionChanged;
  final bool? autoPlayOnVisible;
  final GlobalKey<OptimizedVideoPlayerState>? videoPlayerKey;

  const FeedItemOptimized({
    super.key,
    required this.video,
    this.isVisible = true,
    this.onPlayStateChanged,
    this.onPositionChanged,
    this.autoPlayOnVisible = true,
    this.videoPlayerKey,
  });

  @override
  State<FeedItemOptimized> createState() => _FeedItemOptimizedState();
}

class _FeedItemOptimizedState extends State<FeedItemOptimized>
    with SingleTickerProviderStateMixin {
  final WebSocketService _webSocketService = getIt<WebSocketService>();
  final FeedEventService _feedEventService = getIt<FeedEventService>();
  StreamSubscription<VideoLikeUpdate>? _likeSubscription;
  StreamSubscription<VideoCommentUpdate>? _commentSubscription;
  Timer? _pollingTimer;

  late bool isLiked;
  late int likeCount;
  late int commentCount;
  bool isDoubleTapAnimating = false;
  bool isSmallLikeAnimating = false;
  bool _impressionSent = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.video.isLiked;
    likeCount = widget.video.likeCount;
    commentCount = widget.video.commentCount;

    _setupWebSocket();
    _setupPeriodicPolling();
    if (widget.isVisible) {
      _sendImpressionOnce();
    }
  }

  @override
  void didUpdateWidget(covariant FeedItemOptimized oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      _sendImpressionOnce();
    }
  }

  Future<void> _sendImpressionOnce() async {
    if (_impressionSent) {
      return;
    }
    _impressionSent = true;
    try {
      await _feedEventService.sendImpression(widget.video.id);
    } catch (_) {}
  }

  void _setupWebSocket() {
    if (!_webSocketService.isConnected) {
      _webSocketService.connect();
    }

    _likeSubscription = _webSocketService.subscribe<VideoLikeUpdate>(
      '/topic/video/${widget.video.id}/likes',
      VideoLikeUpdate.fromJson,
    ).listen((update) {
      if (mounted) {
        setState(() {
          likeCount = update.likeCount;
        });
      }
    });

    _commentSubscription = _webSocketService.subscribe<VideoCommentUpdate>(
      '/topic/video/${widget.video.id}/comments',
      VideoCommentUpdate.fromJson,
    ).listen((update) {
      if (mounted) {
        setState(() {
          commentCount = update.commentCount;
        });
      }
    });
  }

  void _setupPeriodicPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // TODO: Implement polling API call to get updated video details
      // This will be implemented later
    });
  }

  @override
  void dispose() {
    _likeSubscription?.cancel();
    _commentSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!isLiked) {
      context.read<InteractionBloc>().add(LikeVideoEvent(widget.video.id));
      setState(() {
        isLiked = true;
        likeCount++;
        isSmallLikeAnimating = true;
      });
    }
    setState(() {
      isDoubleTapAnimating = true;
    });
  }

  void _handleLikeToggle() {
    if (isLiked) {
      context.read<InteractionBloc>().add(UnlikeVideoEvent(widget.video.id));
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      context.read<InteractionBloc>().add(LikeVideoEvent(widget.video.id));
      setState(() {
        isLiked = true;
        likeCount++;
        isSmallLikeAnimating = true;
      });
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return CommentsBottomSheet(videoId: widget.video.id);
          },
        );
      },
    );
  }

  void _navigateToProfile() {
    context.go('/user/${widget.video.uploaderId}');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InteractionBloc, InteractionState>(
      listenWhen: (previous, current) => 
          current.lastActionVideoId == widget.video.id &&
          (previous.commentStatus != current.commentStatus || 
           previous.likeStatus != current.likeStatus),
      listener: (context, state) {
        if (state.commentStatus == InteractionStatus.success) {
          setState(() {
            commentCount++;
          });
        }
        
        if (state.likeStatus == InteractionStatus.failure) {
          // Revert optimistic update on failure
          setState(() {
            isLiked = !isLiked;
            likeCount = isLiked ? likeCount + 1 : likeCount - 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Action failed')),
          );
        }
      },
      child: GestureDetector(
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < -500) {
            // Swipe left detected
            _navigateToProfile();
          }
        },
        child: Stack(
          children: [
            // Optimized Video Player
            GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: OptimizedVideoPlayer(
                key: widget.videoPlayerKey,
                videoUrl: widget.video.videoUrl,
                thumbnailUrl: widget.video.thumbnailUrl,
                videoDuration: Duration(seconds: widget.video.duration),
                isVisible: widget.isVisible,
                onWatchReported: (watchMs) async {
                  try {
                    await _feedEventService.sendWatch(widget.video.id, watchMs);
                  } catch (_) {}
                },
                onPlayStateChanged: widget.onPlayStateChanged,
                onPositionChanged: widget.onPositionChanged,
                autoPlayOnVisible: widget.autoPlayOnVisible,
              ),
            ),


            // Big Heart Animation Center Overlay
            Center(
              child: LikeAnimation(
                isAnimating: isDoubleTapAnimating,
                duration: const Duration(milliseconds: 400),
                onEnd: () {
                  setState(() {
                    isDoubleTapAnimating = false;
                  });
                },
                child: isDoubleTapAnimating
                    ? const Icon(Icons.favorite, color: Colors.white, size: 100)
                    : const SizedBox.shrink(),
              ),
            ),

            // Bottom Info & Actions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Label
                    if (widget.video.isAiGenerated)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.brand.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_fix_high,
                              color: AppColors.brand,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI-Generated',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Description
                    Text(
                      widget.video.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Uploader & Duration Info
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: Text(
                            '@${widget.video.uploaderName}',
                            style: const TextStyle(
                              color: AppColors.brand,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(
                            Duration(seconds: widget.video.duration),
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right Side Actions
            Positioned(
              right: 12,
              bottom: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like Button
                  GestureDetector(
                    onTap: _handleLikeToggle,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color:
                                  isLiked ? Colors.red : Colors.white,
                              size: 32,
                            ),
                            if (isSmallLikeAnimating)
                              LikeAnimation(
                                isAnimating: isSmallLikeAnimating,
                                duration: const Duration(milliseconds: 300),
                                onEnd: () {
                                  setState(() {
                                    isSmallLikeAnimating = false;
                                  });
                                },
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 32,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AnimatedCount(
                          count: likeCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comment Button
                  GestureDetector(
                    onTap: _showComments,
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white.withOpacity(0.9),
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        AnimatedCount(
                          count: commentCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Share Button
                  Column(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // More Options Button
                  Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.9),
                    size: 32,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
