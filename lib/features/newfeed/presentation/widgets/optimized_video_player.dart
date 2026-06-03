import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;
  final Duration? videoDuration;
  final bool isVisible;
  final VoidCallback? onVideoInitialized;
  final ValueChanged<int>? onWatchReported;
  final ValueChanged<bool>? onPlayStateChanged;
  final ValueChanged<Duration>? onPositionChanged;
  final bool? autoPlayOnVisible;

  const OptimizedVideoPlayer({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.videoDuration,
    this.isVisible = true,
    this.onVideoInitialized,
    this.onWatchReported,
    this.onPlayStateChanged,
    this.onPositionChanged,
    this.autoPlayOnVisible = true,
  });

  @override
  State<OptimizedVideoPlayer> createState() => OptimizedVideoPlayerState();
}

class OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  int _watchedMs = 0;
  Duration _lastPosition = Duration.zero;
  bool _isManualControl = false;

  // External control methods
  void seekTo(Duration position) {
    if (_isInitialized && _videoController != null) {
      _isManualControl = true;
      _videoController!.seekTo(position).then((_) {
        _isManualControl = false;
      });
    }
  }

  void play() {
    if (_isInitialized && _videoController != null && !_isPlaying) {
      _isManualControl = true;
      _videoController!.play().then((_) {
        setState(() => _isPlaying = true);
        widget.onPlayStateChanged?.call(true);
        _isManualControl = false;
      });
    }
  }

  void pause() {
    if (_isInitialized && _videoController != null && _isPlaying) {
      _isManualControl = true;
      _videoController!.pause().then((_) {
        setState(() => _isPlaying = false);
        widget.onPlayStateChanged?.call(false);
        _isManualControl = false;
      });
    }
  }

  Duration? getCurrentPosition() {
    if (_isInitialized && _videoController != null) {
      return _videoController!.value.position;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isVisible && widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If visibility changed from false to true, initialize video
    if (oldWidget.isVisible != widget.isVisible && widget.isVisible) {
      if (!_isInitialized && widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _initializeVideo();
      } else if (_isInitialized && _videoController != null && widget.autoPlayOnVisible!) {
        _videoController!.play();
        setState(() => _isPlaying = true);
        widget.onPlayStateChanged?.call(true);
      }
    }
    // If visibility changed from true to false, pause video
    else if (oldWidget.isVisible && !widget.isVisible && _isInitialized && _videoController != null) {
      _flushWatch();
      _videoController!.pause();
      setState(() => _isPlaying = false);
      widget.onPlayStateChanged?.call(false);
    }

    // If video URL changed, reinitialize
    if (oldWidget.videoUrl != widget.videoUrl) {
      _flushWatch();
      _disposeVideo();
      if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _initializeVideo();
      }
    }
  }

  void _initializeVideo() {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return;
    }
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl!),
    )
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _lastPosition = Duration.zero;
          _watchedMs = 0;
          _videoController!.addListener(_onVideoTick);
          widget.onVideoInitialized?.call();
          // Auto-play when visible
          if (widget.isVisible && widget.autoPlayOnVisible!) {
            _videoController!.play();
            setState(() => _isPlaying = true);
            widget.onPlayStateChanged?.call(true);
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

  void _onVideoTick() {
    if (!_isInitialized || !widget.isVisible || _videoController == null) {
      return;
    }
    final value = _videoController!.value;
    if (!value.isInitialized) {
      return;
    }
    
    // Notify position changed
    if (value.position != _lastPosition) {
      widget.onPositionChanged?.call(value.position);
    }
    
    if (!value.isPlaying) {
      _lastPosition = value.position;
      return;
    }
    final pos = value.position;
    final delta = pos - _lastPosition;
    if (delta.inMilliseconds > 0 && delta.inMilliseconds < 10 * 1000) {
      _watchedMs += delta.inMilliseconds;
    }
    _lastPosition = pos;
  }

  void _flushWatch() {
    if (_watchedMs > 0) {
      widget.onWatchReported?.call(_watchedMs);
      _watchedMs = 0;
    }
  }

  void _disposeVideo() {
    if (_isInitialized && _videoController != null) {
      _videoController!.removeListener(_onVideoTick);
      _videoController!.dispose();
      _isInitialized = false;
      _isPlaying = false;
    }
  }

  void _togglePlayPause() {
    if (_isInitialized && _videoController != null) {
      setState(() {
        _isPlaying = !_isPlaying;
        _isPlaying ? _videoController!.play() : _videoController!.pause();
      });
      widget.onPlayStateChanged?.call(_isPlaying);
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
    _flushWatch();
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        child: widget.videoUrl == null || widget.videoUrl!.isEmpty
            ? Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.white),
                ),
              )
            : !_isInitialized
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail while loading
                  if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.thumbnailUrl!,
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
                    )
                  else
                    Container(color: Colors.grey[900]),
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
                  VideoPlayer(_videoController!),
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
                      _videoController!,
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
