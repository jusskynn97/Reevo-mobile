import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:video_player/video_player.dart';

class TrimSliderWidget extends StatefulWidget {
  final double duration;
  final double trimStart;
  final double trimEnd;
  final ValueChanged<double>? onTrimStartChanged;
  final ValueChanged<double>? onTrimEndChanged;
  final VideoPlayerController? videoController;

  const TrimSliderWidget({
    super.key,
    required this.duration,
    required this.trimStart,
    required this.trimEnd,
    this.onTrimStartChanged,
    this.onTrimEndChanged,
    this.videoController,
  });

  @override
  State<TrimSliderWidget> createState() => _TrimSliderWidgetState();
}

class _TrimSliderWidgetState extends State<TrimSliderWidget> {
  late double _trimStart;
  late double _trimEnd;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _trimStart = widget.trimStart;
    _trimEnd = widget.trimEnd;
    widget.videoController?.addListener(_videoListener);
  }

  void _videoListener() {
    if (!mounted) return;
    final controller = widget.videoController;
    if (controller?.value.isInitialized == true) {
      final pos = controller!.value.position.inMilliseconds;
      final total = widget.duration * 1000;
      setState(() {
        _currentPosition = (pos / total).clamp(0.0, 1.0);
      });
    }
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_videoListener);
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final mins = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.duration;

    return Column(
      children: [
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_trimStart * totalSeconds), style: const TextStyle(color: AppColors.grey2, fontSize: 12)),
              Text(
                '${_formatDuration((_trimEnd - _trimStart) * totalSeconds)} / ${_formatDuration(totalSeconds)}',
                style: const TextStyle(color: AppColors.grey1, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 78,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final handleW = 16.0;
              final usableW = width - handleW * 2;

              final startX = _trimStart * usableW;
              final endX = _trimEnd * usableW;
              final currentX = _currentPosition * usableW;

              return Stack(
                children: [
                  // Thumbnail Strip Background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey5.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: List.generate(12, (index) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    "${(index * 8).toString().padLeft(2, '0')}",
                                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // Selected Range Highlight
                  Positioned(
                    left: startX + handleW,
                    width: endX - startX,
                    top: 10,
                    bottom: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.brand, width: 2.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Scrubber (có thể kéo tua)
                  Positioned(
                    left: currentX + handleW - 2,
                    top: 6,
                    bottom: 6,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        final newPos = ((_currentPosition * usableW + details.delta.dx) / usableW)
                            .clamp(0.0, 1.0);
                        setState(() => _currentPosition = newPos);

                        final seekTo = Duration(milliseconds: (newPos * widget.duration * 1000).toInt());
                        widget.videoController?.seekTo(seekTo);
                      },
                      child: Container(
                        width: 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [BoxShadow(color: AppColors.brand.withOpacity(0.8), blurRadius: 8)],
                        ),
                      ),
                    ),
                  ),

                  // Left Trim Handle
                  Positioned(
                    left: startX,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _trimStart = ((_trimStart * usableW + details.delta.dx) / usableW)
                              .clamp(0.0, _trimEnd - 0.05);
                        });
                        widget.onTrimStartChanged?.call(_trimStart);
                      },
                      child: _buildHandle(true),
                    ),
                  ),

                  // Right Trim Handle
                  Positioned(
                    left: endX + handleW,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _trimEnd = ((_trimEnd * usableW + details.delta.dx) / usableW)
                              .clamp(_trimStart + 0.05, 1.0);
                        });
                        widget.onTrimEndChanged?.call(_trimEnd);
                      },
                      child: _buildHandle(false),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(bool isLeft) {
    return Container(
      width: 16,
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: isLeft
            ? const BorderRadius.horizontal(left: Radius.circular(8))
            : const BorderRadius.horizontal(right: Radius.circular(8)),
      ),
      child: const Center(
        child: Icon(Icons.drag_indicator, color: Colors.black87, size: 14),
      ),
    );
  }
}