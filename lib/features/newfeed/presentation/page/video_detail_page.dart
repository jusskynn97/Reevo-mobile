import 'package:flutter/material.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/presentation/widgets/feed_item_optimized.dart';

class VideoDetailPage extends StatelessWidget {
  final String videoId;

  const VideoDetailPage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would fetch the video by ID here.
    // For now, we'll show a placeholder or a mock video.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Video', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Text(
          'Viewing Video ID: $videoId\n(Fetching video logic would go here)',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
