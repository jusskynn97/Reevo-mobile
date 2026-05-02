import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_event.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_state.dart';
import 'package:reevo/features/newfeed/presentation/widgets/feed_item_optimized.dart';

class NewfeedPage extends StatefulWidget {
  const NewfeedPage({super.key});

  @override
  State<NewfeedPage> createState() => _NewfeedPageState();
}

class _NewfeedPageState extends State<NewfeedPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Fetch initial videos
    context.read<VideoFeedBloc>().add(const FetchVideoFeedEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _loadMoreVideos(String? nextCursor) {
    if (nextCursor != null) {
      context.read<VideoFeedBloc>().add(LoadMoreVideoFeedEvent(cursor: nextCursor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<VideoFeedBloc, VideoFeedState>(
        builder: (context, state) {
          if (state is VideoFeedInitial || state is VideoFeedLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
              ),
            );
          } else if (state is VideoFeedSuccess) {
            return Stack(
              children: [
                // Infinite Scroll Feed with PageView
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    _onPageChanged(index);
                    // Load more when reaching near the end
                    if (index >= state.videos.length - 2 &&
                        !state.hasReachedMax &&
                        state.nextCursor != null) {
                      _loadMoreVideos(state.nextCursor);
                    }
                  },
                  itemCount: state.videos.length,
                  itemBuilder: (context, index) {
                    final video = state.videos[index];
                    final isVisible = (_currentPage - index).abs() <= 1;

                    return FeedItemOptimized(
                      video: video,
                      isVisible: isVisible,
                    );
                  },
                ),

                // Top Navigation Overlay
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // VibeSync Logo/Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Reevo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        // Following / For You Tabs
                        Row(
                          children: [
                            const Text(
                              'Following',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'For You',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 24,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Search Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading more indicator
                if (state is VideoFeedLoadingMore)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.brand),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else if (state is VideoFeedFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.brand,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.failure.message ?? 'Failed to load videos'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<VideoFeedBloc>()
                          .add(const RefreshVideoFeedEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}