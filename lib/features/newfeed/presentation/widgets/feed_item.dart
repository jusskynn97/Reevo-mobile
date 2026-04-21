import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/newfeed/presentation/widgets/like_animation.dart';
import 'package:reevo/features/newfeed/presentation/widgets/comments_bottom_sheet.dart';

class FeedItem extends StatefulWidget {
  final int index;

  const FeedItem({super.key, required this.index});

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final List<Color> mockVideoColors = [
      Colors.blueGrey.shade800,
      Colors.indigo.shade800,
      Colors.teal.shade800,
      Colors.brown.shade800,
    ];

    final color = mockVideoColors[widget.index % mockVideoColors.length];

    return Stack(
      children: [
        // Fake Video Background
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: color,
            child: Center(
              child: Text(
                'Fake Video ${widget.index + 1}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

        // Bottom Progress Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                const Text('0:45', style: TextStyle(color: Colors.white, fontSize: 10)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100, // Hardcoded for visual
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('2:30', style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),

        // Bottom-Left Info Overlay
        Positioned(
          bottom: 32,
          left: 16,
          right: 80, // Leave space for right actions
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=1'), // Placeholder avatar
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '@sarah_v',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: AppColors.brand, size: 14),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.brand, width: 1.5),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '549 followers',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Exploring the neon depths. ☔ neon vibes everywhere! The city never sleeps when you\'re chasing the perfect shot. #citywalk #nightlife #cyberpunk',
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.music_note_rounded, color: AppColors.brand, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Original Sound - Synthwave',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom-Right Actions Overlay
        Positioned(
          bottom: 32,
          right: 12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Like
              GestureDetector(
                onTap: _handleLikeToggle,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: LikeAnimation(
                        isAnimating: isSmallLikeAnimating,
                        duration: const Duration(milliseconds: 200),
                        onEnd: () => setState(() => isSmallLikeAnimating = false),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: isLiked ? AppColors.brand : Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('12.4K', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Comment
              GestureDetector(
                onTap: _showComments,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 4),
                    const Text('842', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Save
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 4),
                  const Text('Save', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              // Share
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.reply_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 4),
                  const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              // Repost
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cached_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),

              // Vinyl Record Graphic
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brand, width: 1.5),
                ),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=1'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
