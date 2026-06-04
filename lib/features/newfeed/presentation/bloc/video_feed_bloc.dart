import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/domain/usecase/get_video_feed_usecase.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_event.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_state.dart';

class VideoFeedBloc extends Bloc<VideoFeedEvent, VideoFeedState> {
  final GetVideoFeedUseCase getVideoFeedUseCase;

  VideoFeedBloc({required this.getVideoFeedUseCase})
      : super(const VideoFeedInitial()) {
    on<FetchVideoFeedEvent>(_onFetchVideoFeed);
    on<LoadMoreVideoFeedEvent>(_onLoadMoreVideoFeed);
    on<RefreshVideoFeedEvent>(_onRefreshVideoFeed);
  }

  Future<void> _onFetchVideoFeed(
    FetchVideoFeedEvent event,
    Emitter<VideoFeedState> emit,
  ) async {
    emit(const VideoFeedLoading());

    final result = await getVideoFeedUseCase(
      GetVideoFeedParams(cursor: event.cursor, limit: 10),
    );

    result.fold(
      (failure) {
        emit(VideoFeedFailure(failure: failure));
      },
      (feed) {
        emit(VideoFeedSuccess(
          videos: feed.items,
          nextCursor: feed.nextCursor,
          hasReachedMax: feed.nextCursor == null,
        ));
      },
    );
  }

  Future<void> _onLoadMoreVideoFeed(
    LoadMoreVideoFeedEvent event,
    Emitter<VideoFeedState> emit,
  ) async {
    final currentState = state;

    if (currentState is VideoFeedSuccess) {
      if (currentState.hasReachedMax) {
        return;
      }

      emit(VideoFeedLoadingMore(
        videos: currentState.videos,
        nextCursor: currentState.nextCursor,
      ));

      final result = await getVideoFeedUseCase(
        GetVideoFeedParams(cursor: event.cursor, limit: 10),
      );

      result.fold(
        (failure) {
          emit(VideoFeedFailure(failure: failure));
        },
        (feed) {
          final List<VideoEntity> updatedVideos = [
            ...currentState.videos,
            ...feed.items,
          ];

          emit(VideoFeedSuccess(
            videos: updatedVideos,
            nextCursor: feed.nextCursor,
            hasReachedMax: feed.nextCursor == null,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshVideoFeed(
    RefreshVideoFeedEvent event,
    Emitter<VideoFeedState> emit,
  ) async {
    emit(const VideoFeedLoading());

    final result = await getVideoFeedUseCase(
      const GetVideoFeedParams(cursor: null, limit: 10),
    );

    result.fold(
      (failure) {
        emit(VideoFeedFailure(failure: failure));
      },
      (feed) {
        emit(VideoFeedSuccess(
          videos: feed.items,
          nextCursor: feed.nextCursor,
          hasReachedMax: feed.nextCursor == null,
        ));
      },
    );
  }
}
