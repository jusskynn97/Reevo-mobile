import 'package:equatable/equatable.dart';

abstract class VideoFeedEvent extends Equatable {
  const VideoFeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchVideoFeedEvent extends VideoFeedEvent {
  final String? cursor;

  const FetchVideoFeedEvent({this.cursor});

  @override
  List<Object?> get props => [cursor];
}

class LoadMoreVideoFeedEvent extends VideoFeedEvent {
  final String? cursor;

  const LoadMoreVideoFeedEvent({required this.cursor});

  @override
  List<Object?> get props => [cursor];
}

class RefreshVideoFeedEvent extends VideoFeedEvent {
  const RefreshVideoFeedEvent();
}
