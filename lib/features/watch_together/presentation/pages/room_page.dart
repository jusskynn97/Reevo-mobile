
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/watch_room_service.dart';
import 'package:reevo/core/services/websocket_service.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_event.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_state.dart';
import 'package:reevo/features/newfeed/presentation/widgets/feed_item_optimized.dart';
import 'package:reevo/features/newfeed/presentation/widgets/optimized_video_player.dart';
import '../../domain/entity/video_change_event_entity.dart';
import '../../domain/entity/video_sync_event_entity.dart';
import '../bloc/room_bloc.dart';

class RoomPage extends StatefulWidget {
  final String roomId;

  const RoomPage({super.key, required this.roomId});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with TickerProviderStateMixin {
  late final PageController _pageController;
  final WatchRoomService _watchRoomService = getIt<WatchRoomService>();
  final WebSocketService _webSocketService = getIt<WebSocketService>();
  late final RoomBloc _roomBloc;
  late final VideoFeedBloc _videoFeedBloc;
  final TextEditingController _chatController = TextEditingController();

  int _currentPage = 0;
  bool _isChatOpen = false;
  bool _isMicMuted = true;
  VideoChangeEventEntity? _lastVideoChangeEvent;
  VideoSyncEventEntity? _lastReceivedSyncEvent;

  // Store keys to access video players
  final Map<int, GlobalKey<OptimizedVideoPlayerState>> _videoPlayerKeys = {};

  // Track host play state and position for sync
  bool _hostPlaying = false;
  Duration _lastSentPosition = Duration.zero;
  bool _lastSentPlaying = false;

  // Timer to send sync events from host
  Timer? _syncTimer;

  // To track if we have initial video set
  bool _hasInitialVideo = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _roomBloc = getIt<RoomBloc>();
    _videoFeedBloc = getIt<VideoFeedBloc>()..add(const FetchVideoFeedEvent());
    _roomBloc.add(InitializeRoom(widget.roomId));

    // If we're host, start sync timer to send updates periodically
    if (_watchRoomService.isHost) {
      _startHostSync();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _roomBloc.close();
    _syncTimer?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _startHostSync() {
    // Send sync event every 1.5 seconds (reduced frequency)
    _syncTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _sendHostSyncEvent(force: false);
    });
  }

  void _sendHostSyncEvent({bool force = false}) {
    // Get current video player key
    final currentKey = _videoPlayerKeys[_currentPage];
    if (currentKey != null && currentKey.currentState != null) {
      final playerState = currentKey.currentState!;
      final position = playerState.getCurrentPosition() ?? Duration.zero;

      // Only send if position changed by > 200ms OR playing state changed OR forced
      if (force ||
          (position - _lastSentPosition).abs().inMilliseconds > 200 ||
          (_hostPlaying != _lastSentPlaying)) {
        // Send sync event via RoomBloc
        _roomBloc.add(SendVideoSync(
          type: 'sync',
          position: position.inMilliseconds,
          playing: _hostPlaying,
        ));

        // Update last sent values
        _lastSentPosition = position;
        _lastSentPlaying = _hostPlaying;
      }
    }
  }

  void _handleHostPlayStateChanged(bool isPlaying) {
    setState(() {
      _hostPlaying = isPlaying;
    });
    // Send sync right away
    _sendHostSyncEvent(force: true);
  }

  void _onPageChanged(int index, List<VideoEntity> videos) {
    setState(() => _currentPage = index);

    if (_watchRoomService.isHost && _watchRoomService.currentRoom != null) {
      final video = videos[index];
      _roomBloc.add(ChangeVideo(
        videoId: video.id,
        videoUrl: video.videoUrl,
        thumbnailUrl: video.thumbnailUrl,
      ));
      // Send sync right after changing video (wait for video to be ready)
      Future.delayed(const Duration(milliseconds: 1000), () {
        _sendHostSyncEvent(force: true);
      });
    }
  }

  void _handleVideoSyncEvent(VideoSyncEventEntity syncEvent) {
    // If we are host, ignore sync events
    if (_watchRoomService.isHost) return;

    // Get the current video player key
    final currentKey = _videoPlayerKeys[_currentPage];
    if (currentKey != null && currentKey.currentState != null) {
      final playerState = currentKey.currentState!;
      final currentPosition = playerState.getCurrentPosition() ?? Duration.zero;
      final targetPosition = Duration(milliseconds: syncEvent.position);

      // Only seek if difference > 500ms to avoid micro-seeks
      if ((currentPosition - targetPosition).abs().inMilliseconds > 500) {
        playerState.seekTo(targetPosition);
      }

      // Handle play/pause only if state changed
      if (syncEvent.playing != null) {
        final wasPlaying = _lastReceivedSyncEvent?.playing;
        if (wasPlaying != syncEvent.playing) {
          if (syncEvent.playing == true) {
            playerState.play();
          } else {
            playerState.pause();
          }
        }
      }

      _lastReceivedSyncEvent = syncEvent;
    }
  }

  // Handle video change: find video, jump to it, and sync
  void _handleVideoChange(VideoChangeEventEntity videoChangeEvent) {
    // Check if we already processed this exact event
    if (_lastVideoChangeEvent != null &&
        _lastVideoChangeEvent!.videoId == videoChangeEvent.videoId &&
        _lastVideoChangeEvent!.timestamp == videoChangeEvent.timestamp) {
      return; // Skip duplicate
    }

    _lastVideoChangeEvent = videoChangeEvent;

    // If we are host, do nothing special
    if (_watchRoomService.isHost) return;

    // Try to find the video in the current feed
    final currentFeedState = _videoFeedBloc.state;
    if (currentFeedState is VideoFeedSuccess) {
      final videoIndex = currentFeedState.videos.indexWhere(
        (video) => video.id == videoChangeEvent.videoId,
      );

      if (videoIndex != -1) {
        setState(() {
          _currentPage = videoIndex;
        });
        _pageController.jumpToPage(videoIndex);

        // Reset sync state for new video
        _lastReceivedSyncEvent = null;

        // Wait for video to initialize and then sync
        Future.delayed(const Duration(milliseconds: 1200), () {
          final currentKey = _videoPlayerKeys[_currentPage];
          if (currentKey != null && currentKey.currentState != null) {
            final playerState = currentKey.currentState!;

            // If we have a sync event, use it
            final currentState = _roomBloc.state;
            if (currentState is RoomLoaded && currentState.videoSyncEvent != null) {
              final targetPosition = Duration(milliseconds: currentState.videoSyncEvent!.position);
              final shouldPlay = currentState.videoSyncEvent!.playing ?? true;
              playerState.forceSyncAndPlay(targetPosition, shouldPlay);
              _lastReceivedSyncEvent = currentState.videoSyncEvent;
            } else {
              // If no sync event yet, just play from beginning
              playerState.play();
            }
          }
        });
      }
    }
  }

  // When a new participant joins, host should send full sync
  void _handleParticipantJoined() {
    if (_watchRoomService.isHost) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _sendHostSyncEvent(force: true);
      });
    }
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    
    _roomBloc.add(SendMessage(_chatController.text.trim()));
    _chatController.clear();
  }

  Future<void> _leaveRoom() async {
    if (_watchRoomService.isHost) {
      // If host, delete room
      _roomBloc.add(DeleteRoom(widget.roomId));
    } else {
      // If guest, just leave
      _roomBloc.add(const LeaveRoom());
    }
    
    _watchRoomService.leaveRoom();
    Navigator.of(context).pop();
  }

  void _openParticipants() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocBuilder<RoomBloc, RoomState>(
        bloc: _roomBloc,
        builder: (context, state) {
          if (state is RoomLoaded) {
            final roomLoadedState = state;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participants (${roomLoadedState.participants.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: roomLoadedState.participants.length,
                      itemBuilder: (context, index) {
                        final participant = roomLoadedState.participants[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: participant.avatarUrl != null
                                ? NetworkImage(participant.avatarUrl!)
                                : null,
                            backgroundColor: AppColors.surfaceLight,
                            child: participant.avatarUrl == null
                                ? Text(
                                    participant.username[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                          title: Text(
                            participant.username,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            participant.isHost ? 'Host' : 'Member',
                            style: const TextStyle(color: AppColors.grey3),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MultiBlocListener(
        listeners: [
          BlocListener<RoomBloc, RoomState>(
            bloc: _roomBloc,
            listener: (context, state) {
              if (state is RoomLoaded) {
                // Handle initial video when room first loads
                if (!_hasInitialVideo && state.videoChangeEvent != null) {
                  _hasInitialVideo = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleVideoChange(state.videoChangeEvent!);
                  });
                }

                // Handle video change every time videoChangeEvent is present
                if (state.videoChangeEvent != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleVideoChange(state.videoChangeEvent!);
                  });
                }

                // Handle video sync every time videoSyncEvent is present
                if (state.videoSyncEvent != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleVideoSyncEvent(state.videoSyncEvent!);
                  });
                }
              }
            },
          ),
        ],
        child: BlocBuilder<VideoFeedBloc, VideoFeedState>(
          bloc: _videoFeedBloc,
          builder: (context, feedState) {
            if (feedState is VideoFeedInitial ||
                feedState is VideoFeedLoading) {
              return _buildLoadingState();
            } else if (feedState is VideoFeedSuccess ||
                feedState is VideoFeedLoadingMore) {
              final videos = feedState is VideoFeedSuccess
                  ? feedState.videos
                  : (feedState as VideoFeedLoadingMore).videos;
              final isLoadingMore = feedState is VideoFeedLoadingMore;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Video Feed
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: _watchRoomService.isHost
                        ? const PageScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      _onPageChanged(index, videos);
                    },
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      // Create or get the key for this video
                      if (!_videoPlayerKeys.containsKey(index)) {
                        _videoPlayerKeys[index] =
                            GlobalKey<OptimizedVideoPlayerState>();
                      }

                      final video = videos[index];
                      final isVisible =
                          (_currentPage - index).abs() <= 1;

                      return FeedItemOptimized(
                        key: ValueKey(video.id),
                        video: video,
                        isVisible: isVisible,
                        videoPlayerKey: _videoPlayerKeys[index],
                        autoPlayOnVisible: _watchRoomService.isHost,
                        onPlayStateChanged: (isPlaying) {
                          if (_watchRoomService.isHost) {
                            _handleHostPlayStateChanged(isPlaying);
                          }
                        },
                      );
                    },
                  ),

                  // Top Bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 24),
                                onPressed: _leaveRoom,
                              ),
                            ),

                            // Room Name
                            BlocBuilder<RoomBloc, RoomState>(
                              bloc: _roomBloc,
                              builder: (context, state) {
                                String roomName = 'Loading...';
                                if (state is RoomLoaded) {
                                  final roomLoadedState = state;
                                  roomName = roomLoadedState.room.name;
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    roomName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Participants Button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.people,
                                    color: Colors.white, size: 24),
                                onPressed: _openParticipants,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Right Controls (when chat is closed)
                  if (!_isChatOpen)
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Chat Button
                          GestureDetector(
                            onTap: () {
                              setState(() => _isChatOpen = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Mic Button
                          GestureDetector(
                            onTap: () {
                              setState(() => _isMicMuted = !_isMicMuted);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isMicMuted
                                    ? Colors.black.withOpacity(0.6)
                                    : AppColors.brand,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isMicMuted ? Icons.mic_off : Icons.mic,
                                color: _isMicMuted ? Colors.white : Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bottom Chat Input (when chat is closed)
                  if (!_isChatOpen)
                    Positioned(
                      left: 16,
                      right: 80,
                      bottom: 100,
                      child: SafeArea(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: AppColors.brand),
                                onPressed: _sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Chat Overlay
                  if (_isChatOpen) ...[
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isChatOpen = false);
                        },
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: BlocBuilder<RoomBloc, RoomState>(
                          bloc: _roomBloc,
                          builder: (context, roomState) {
                            if (roomState is RoomLoaded) {
                              final roomLoadedState = roomState;
                              return Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey2,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Chat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      itemCount: roomLoadedState.messages.length,
                                      itemBuilder: (context, index) {
                                        final message =
                                            roomLoadedState.messages[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundImage:
                                                    message.senderAvatarUrl !=
                                                            null
                                                        ? NetworkImage(message
                                                            .senderAvatarUrl!)
                                                        : null,
                                                backgroundColor:
                                                    AppColors.surfaceLight,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      message.senderUsername,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      message.content,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Chat Input in overlay
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _chatController,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: 'Type a message...',
                                                hintStyle: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 14,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                border: InputBorder.none,
                                              ),
                                              onSubmitted: (_) => _sendMessage(),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.send,
                                                color: AppColors.brand),
                                            onPressed: _sendMessage,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  ],

                  // Loading More Indicator
                  if (isLoadingMore)
                    Positioned(
                      bottom: 200,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppColors.brand),
                              SizedBox(width: 8),
                              Text(
                                'Loading more...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            } else if (feedState is VideoFeedFailure) {
              return _buildErrorState(feedState);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

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
            'Loading room...',
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
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

