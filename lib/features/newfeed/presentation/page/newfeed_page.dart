import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/watch_room_service.dart';
import 'package:reevo/core/services/websocket_service.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_event.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_state.dart';
import 'package:reevo/features/newfeed/presentation/widgets/feed_item_optimized.dart';
import 'package:reevo/features/upload/presentation/bloc/upload_cubit.dart';

class NewfeedPage extends StatefulWidget {
  const NewfeedPage({super.key});

  @override
  State<NewfeedPage> createState() => _NewfeedPageState();
}

class _NewfeedPageState extends State<NewfeedPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _tabAnimController;
  late final Animation<double> _tabFadeAnim;
  final WatchRoomService _watchRoomService = getIt<WatchRoomService>();
  final WebSocketService _webSocketService = getIt<WebSocketService>();

  int _currentPage = 0;
  int _activeTab = 1; // 0 = Following, 1 = For You

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tabFadeAnim = CurvedAnimation(
      parent: _tabAnimController,
      curve: Curves.easeOut,
    );
    _tabAnimController.forward();
    context.read<VideoFeedBloc>().add(const FetchVideoFeedEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabAnimController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, List<dynamic> videos) {
    setState(() => _currentPage = index);
    
    // If user is host, send video change event to all participants
    if (_watchRoomService.isHost && _watchRoomService.currentRoom != null) {
      final video = videos[index];
      _webSocketService.send(
        '/app/room/${_watchRoomService.currentRoom!.id}/video-change',
        {
          'videoId': video.id,
          'videoUrl': video.videoUrl,
          'thumbnailUrl': video.thumbnailUrl,
        },
      );
    }
  }

  void _onTabChanged(int tab) {
    setState(() => _activeTab = tab);
    _tabAnimController.forward(from: 0);
  }

  void _loadMoreVideos(String? nextCursor) {
    if (nextCursor != null) {
      context
          .read<VideoFeedBloc>()
          .add(LoadMoreVideoFeedEvent(cursor: nextCursor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<VideoFeedBloc, VideoFeedState>(
        builder: (context, state) {
          if (state is VideoFeedInitial || state is VideoFeedLoading) {
            return _buildLoadingState();
          } else if (state is VideoFeedSuccess ||
              state is VideoFeedLoadingMore) {
            final videos = state is VideoFeedSuccess
                ? state.videos
                : (state as VideoFeedLoadingMore).videos;
            final nextCursor = state is VideoFeedSuccess
                ? state.nextCursor
                : null;
            final hasReachedMax = state is VideoFeedSuccess
                ? state.hasReachedMax
                : true;
            final isLoadingMore = state is VideoFeedLoadingMore;

            return Stack(
              fit: StackFit.expand,
              children: [
                // ── Video Feed ──────────────────────────────────────────
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    _onPageChanged(index, videos);
                    if (index >= videos.length - 2 &&
                        !hasReachedMax &&
                        nextCursor != null) {
                      _loadMoreVideos(nextCursor);
                    }
                  },
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final isVisible = (_currentPage - index).abs() <= 1;
                    return FeedItemOptimized(
                      key: ValueKey(video.id),
                      video: video,
                      isVisible: isVisible,
                    );
                  },
                ),

                // ── Top Gradient Scrim ───────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 160,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.72),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Top Navigation Bar ───────────────────────────────────
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo pill
                            _LogoPill(),

                            const Spacer(),

                            // Tab switcher — centered
                            FadeTransition(
                              opacity: _tabFadeAnim,
                              child: _TabSwitcher(
                                activeTab: _activeTab,
                                onChanged: _onTabChanged,
                              ),
                            ),

                            const Spacer(),


                            // Search button
                            _IconButton(
                              icon: Icons.search_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      
                      // Inline Upload Status
                      BlocBuilder<UploadCubit, UploadState>(
                        bloc: getIt<UploadCubit>(),
                        builder: (context, uploadState) {
                          if (uploadState.isUploading) {
                            return _UploadStatusPill(
                              message: 'Uploading video...',
                              isError: false,
                            );
                          } else if (uploadState.uploadError != null) {
                            return _UploadStatusPill(
                              message: 'Upload failed',
                              isError: true,
                              onRetry: () => getIt<UploadCubit>().retryUpload(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),

                // ── Loading More Indicator ───────────────────────────────
                if (isLoadingMore)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _LoadingMorePill(),
                    ),
                  ),
              ],
            );
          } else if (state is VideoFeedFailure) {
            return _buildErrorState(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── States ─────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading feed...',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VideoFeedFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.brand.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brand.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: AppColors.brand,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.failure.message ?? 'Failed to load videos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _RetryButton(
              onTap: () => context
                  .read<VideoFeedBloc>()
                  .add(const RefreshVideoFeedEvent()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Sub-widgets ──────────────────────────────────────────────────

class _LogoPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      child: const Text(
        'Reevo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onChanged;

  const _TabSwitcher({
    required this.activeTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TabItem(
          label: 'Following',
          isActive: activeTab == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 4),
        Container(
          width: 1,
          height: 14,
          color: Colors.white.withOpacity(0.2),
        ),
        const SizedBox(width: 4),
        _TabItem(
          label: 'For You',
          isActive: activeTab == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white38,
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: isActive ? -0.2 : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: isActive ? 20 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 0.8,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _LoadingMorePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brand.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Loading more...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadStatusPill extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  const _UploadStatusPill({
    required this.message,
    required this.isError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withOpacity(0.9) : AppColors.brand.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isError)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          else
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: isError ? Colors.white : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isError && onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RetryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          'Try again',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}