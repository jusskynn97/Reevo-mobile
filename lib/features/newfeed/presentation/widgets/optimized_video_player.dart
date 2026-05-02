import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final Duration? videoDuration;
  final bool isVisible;
  final VoidCallback? onVideoInitialized;

  const OptimizedVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.videoDuration,
    this.isVisible = true,
    this.onVideoInitialized,
  });

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If visibility changed from false to true, initialize video
    if (oldWidget.isVisible != widget.isVisible && widget.isVisible) {
      if (!_isInitialized) {
        _initializeVideo();
      } else {
        _videoController.play();
        setState(() => _isPlaying = true);
      }
    }
    // If visibility changed from true to false, pause video
    else if (oldWidget.isVisible && !widget.isVisible) {
      _videoController.pause();
      setState(() => _isPlaying = false);
    }

    // If video URL changed, reinitialize
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeVideo();
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          widget.onVideoInitialized?.call();
          // Auto-play when visible
          if (widget.isVisible) {
            _videoController.play();
            setState(() => _isPlaying = true);
          }
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading video: $error')),
          );
        }
      });
  }

  void _disposeVideo() {
    if (_isInitialized) {
      _videoController.dispose();
      _isInitialized = false;
      _isPlaying = false;
    }
  }

  void _togglePlayPause() {
    if (_isInitialized) {
      setState(() {
        _isPlaying = !_isPlaying;
        _isPlaying ? _videoController.play() : _videoController.pause();
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        child: !_isInitialized
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail while loading
                  CachedNetworkImage(
                    imageUrl: widget.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                  // Play button
                  const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  // Video player
                  VideoPlayer(_videoController),
                  // Play/Pause overlay
                  if (!_isPlaying)
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  // Video progress bar at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoProgressIndicator(
                      _videoController,
                      allowScrubbing: false,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
