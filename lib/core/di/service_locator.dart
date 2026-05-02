import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:reevo/features/newfeed/data/datasource/video_remote_datasource.dart';
import 'package:reevo/features/newfeed/data/repository/video_repository_impl.dart';
import 'package:reevo/features/newfeed/domain/repository/video_repository.dart';
import 'package:reevo/features/newfeed/domain/usecase/get_video_feed_usecase.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.0.3:8080', // Change to your API base URL
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  getIt.registerSingleton<Dio>(dio);

  // Data Sources
  getIt.registerSingleton<VideoRemoteDataSource>(
    VideoRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl: 'http://192.168.0.3:8080', // Change to your API base URL
    ),
  );

  // Repositories
  getIt.registerSingleton<VideoRepository>(
    VideoRepositoryImpl(
      remoteDataSource: getIt<VideoRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<GetVideoFeedUseCase>(
    GetVideoFeedUseCase(getIt<VideoRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<VideoFeedBloc>(
    VideoFeedBloc(
      getVideoFeedUseCase: getIt<GetVideoFeedUseCase>(),
    ),
  );
}
