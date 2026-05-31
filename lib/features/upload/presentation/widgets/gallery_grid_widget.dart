import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:reevo/core/theme/color.dart';

class GalleryGridWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<AssetEntity> onVideoSelected;

  const GalleryGridWidget({
    super.key,
    this.selectedIndex = -1,
    required this.onVideoSelected,
  });

  @override
  State<GalleryGridWidget> createState() => _GalleryGridWidgetState();
}

class _GalleryGridWidgetState extends State<GalleryGridWidget> {
  List<AssetEntity> _videos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Request Permission
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (!ps.hasAccess) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No access to library. Please grant permission.';
        });
        return;
      }

      // Get Video Albums
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      );

      if (paths.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No videos found in the library.';
        });
        return;
      }

      // Get recent videos
      final List<AssetEntity> videos = await paths[0].getAssetListRange(
        start: 0,
        end: 100, // Lấy tối đa 100 video gần nhất
      );

      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading gallery: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Have error while loading videos. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadVideos,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text('No videos found in the library.', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final asset = _videos[index];
        final isSelected = index == widget.selectedIndex;

        return GestureDetector(
          onTap: () => widget.onVideoSelected(asset),
          child: Stack(
            children: [
              // Thumbnail
              Positioned.fill(
                child: AssetEntityImage(
                  asset,
                  thumbnailSize: const ThumbnailSize(300, 300),
                  fit: BoxFit.cover,
                ),
              ),

              // Duration
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Selected Border
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.brand, width: 3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

              if (isSelected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.brand,
                    child: Icon(Icons.check, color: Colors.black, size: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}