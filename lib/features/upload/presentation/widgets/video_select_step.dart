import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/upload/presentation/widgets/gallery_grid_widget.dart';
import 'package:reevo/features/upload/presentation/widgets/trim_slider_widget.dart';
import 'package:video_player/video_player.dart';

class VideoSelectStep extends StatefulWidget {
  final AssetEntity? selectedVideo;
  final double trimStart;
  final double trimEnd;
  final double videoDuration;

  final ValueChanged<AssetEntity> onVideoSelected;
  final ValueChanged<double> onTrimStartChanged;
  final ValueChanged<double> onTrimEndChanged;

  const VideoSelectStep({
    super.key,
    required this.selectedVideo,
    required this.trimStart,
    required this.trimEnd,
    required this.videoDuration,
    required this.onVideoSelected,
    required this.onTrimStartChanged,
    required this.onTrimEndChanged,
  });

  @override
  State<VideoSelectStep> createState() => _VideoSelectStepState();
}

class _VideoSelectStepState extends State<VideoSelectStep> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isGalleryExpanded = true;

  @override
  void didUpdateWidget(covariant VideoSelectStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedVideo != widget.selectedVideo) {
      _initializeVideo();
      if (widget.selectedVideo != null) {
        setState(() => _isGalleryExpanded = false);
      }
    }
  }

  Future<void> _initializeVideo() async {
    await _videoController?.dispose();
    _isInitialized = false;

    if (widget.selectedVideo == null) return;

    try {
      final file = await widget.selectedVideo!.file;
      if (file == null) return;

      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.pause();

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoSelected = widget.selectedVideo != null;
    final previewHeight = isVideoSelected && !_isGalleryExpanded ? 440.0 : 340.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Video Preview - Phóng to khi gallery thu gọn
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: EdgeInsets.symmetric(horizontal: isVideoSelected && !_isGalleryExpanded ? 12 : 32),
            height: previewHeight,
            child: _buildVideoPreview(),
          ),

          const SizedBox(height: 20),

          // Trim Slider (đã nâng cấp)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TrimSliderWidget(
              duration: widget.videoDuration,
              trimStart: widget.trimStart,
              trimEnd: widget.trimEnd,
              onTrimStartChanged: widget.onTrimStartChanged,
              onTrimEndChanged: widget.onTrimEndChanged,
              videoController: _videoController,
            ),
          ),

          const SizedBox(height: 24),
          _buildRecentsHeader(),
          const SizedBox(height: 12),

          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: _isGalleryExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GalleryGridWidget(
                      selectedIndex: -1,
                      onVideoSelected: widget.onVideoSelected,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (widget.selectedVideo == null) {
      return _buildMockPreview();
    }

    if (!_isInitialized || _videoController == null) {
      return _buildLoadingPreview();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),

          // Play/Pause Button lớn ở giữa
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              ),
              child: Icon(
                _videoController!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRecentsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            'Recents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey2, size: 20),
          const Spacer(),

          // Nút toggle expand/collapse
          if (widget.selectedVideo != null)
            GestureDetector(
              onTap: () {
                setState(() => _isGalleryExpanded = !_isGalleryExpanded);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grey5,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      _isGalleryExpanded ? 'Hide' : 'Show Gallery',
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isGalleryExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingPreview() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        height: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black87,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.brand),
        ),
      ),
    );
  }

  Widget _buildMockPreview() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        height: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2647), Color(0xFF061326)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF0A1628)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 40,
                right: 40,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.brand.withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _SkylinePainter(),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [const Color(0xFF1A3A5C).withOpacity(0.8), const Color(0xFF0D1B2A).withOpacity(0.9)],
                      ),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.brand.withOpacity(0.4),
                      size: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.brand.withOpacity(0.05), AppColors.brand.withOpacity(0.02)],
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.brand.withOpacity(0.2), width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  
}

/// Paints a minimal city skyline silhouette
class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A3050)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    final buildings = [
      [0.0, 0.6], [0.08, 0.4], [0.15, 0.7], [0.22, 0.3], [0.28, 0.5],
      [0.35, 0.2], [0.42, 0.45], [0.48, 0.55], [0.55, 0.35], [0.62, 0.15],
      [0.68, 0.4], [0.75, 0.5], [0.82, 0.25], [0.88, 0.55], [0.95, 0.45], [1.0, 0.6],
    ];

    for (int i = 0; i < buildings.length; i++) {
      final x = buildings[i][0] * size.width;
      final y = buildings[i][1] * size.height;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}