import 'package:equatable/equatable.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';

abstract class VideoFeedState extends Equatable {
  const VideoFeedState();

  @override
  List<Object?> get props => [];
}

class VideoFeedInitial extends VideoFeedState {
  const VideoFeedInitial();
}

class VideoFeedLoading extends VideoFeedState {
  const VideoFeedLoading();
}

class VideoFeedLoadingMore extends VideoFeedState {
  final List<VideoEntity> videos;
  final String? nextCursor;

  const VideoFeedLoadingMore({
    required this.videos,
    required this.nextCursor,
  });

  @override
  List<Object?> get props => [videos, nextCursor];
}

class VideoFeedSuccess extends VideoFeedState {
  final List<VideoEntity> videos;
  final String? nextCursor;
  final bool hasReachedMax;

  const VideoFeedSuccess({
    required this.videos,
    required this.nextCursor,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [videos, nextCursor, hasReachedMax];

  VideoFeedSuccess copyWith({
    List<VideoEntity>? videos,
    String? nextCursor,
    bool? hasReachedMax,
  }) {
    return VideoFeedSuccess(
      videos: videos ?? this.videos,
      nextCursor: nextCursor ?? this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class VideoFeedFailure extends VideoFeedState {
  final Failure failure;

  const VideoFeedFailure({required this.failure});

  @override
  List<Object?> get props => [failure];
}
