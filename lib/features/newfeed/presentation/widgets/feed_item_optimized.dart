import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/presentation/widgets/optimized_video_player.dart';
import 'package:reevo/features/newfeed/presentation/widgets/like_animation.dart';
import 'package:reevo/features/newfeed/presentation/widgets/comments_bottom_sheet.dart';

class FeedItemOptimized extends StatefulWidget {
  final VideoEntity video;
  final bool isVisible;

  const FeedItemOptimized({
    super.key,
    required this.video,
    this.isVisible = true,
  });

  @override
  State<FeedItemOptimized> createState() => _FeedItemOptimizedState();
}

class _FeedItemOptimizedState extends State<FeedItemOptimized>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool isDoubleTapAnimating = false;
  bool isSmallLikeAnimating = false;

  void _handleDoubleTap() {
    setState(() {
      isLiked = true;
      isDoubleTapAnimating = true;
      isSmallLikeAnimating = true;
    });
  }

  void _handleLikeToggle() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        isSmallLikeAnimating = true;
      }
    });
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
            return const CommentsBottomSheet();
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Optimized Video Player
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: OptimizedVideoPlayer(
            videoUrl: widget.video.videoUrl,
            thumbnailUrl: widget.video.thumbnailUrl,
            videoDuration: Duration(seconds: widget.video.duration),
            isVisible: widget.isVisible,
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
                // Video Info
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
                    Text(
                      '@${widget.video.uploaderName}',
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                    const Text(
                      '0',
                      style: TextStyle(
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
                    const Text(
                      '0',
                      style: TextStyle(
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
    );
  }
}
