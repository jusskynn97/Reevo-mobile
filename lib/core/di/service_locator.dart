import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reevo/core/services/token_storage_service.dart';
import 'package:reevo/core/services/token_interceptor.dart';
import 'package:reevo/core/services/notification_service.dart';
import 'package:reevo/core/services/websocket_service.dart';
import 'package:reevo/core/services/feed_event_service.dart';
import 'package:reevo/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:reevo/features/auth/data/repository/auth_repository_impl.dart';
import 'package:reevo/features/auth/domain/repository/auth_repository.dart';
import 'package:reevo/features/auth/domain/usecase/auth_usecase.dart';
import 'package:reevo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reevo/features/newfeed/data/datasource/video_remote_datasource.dart';
import 'package:reevo/features/newfeed/data/repository/video_repository_impl.dart';
import 'package:reevo/features/newfeed/domain/repository/video_repository.dart';
import 'package:reevo/features/newfeed/domain/usecase/get_video_feed_usecase.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';
import 'package:reevo/features/upload/data/datasource/upload_remote_datasource.dart';
import 'package:reevo/features/upload/data/repository/upload_repository_impl.dart';
import 'package:reevo/features/upload/domain/repository/upload_repository.dart';
import 'package:reevo/features/upload/domain/usecase/upload_video_usecase.dart';
import 'package:reevo/features/upload/presentation/bloc/upload_cubit.dart';
import 'package:reevo/features/user/data/datasource/user_remote_datasource.dart';
import 'package:reevo/features/user/data/repository/user_repository_impl.dart';
import 'package:reevo/features/user/domain/repository/user_repository.dart';
import 'package:reevo/features/user/presentation/bloc/user_bloc.dart';
import 'package:reevo/features/interaction/data/datasource/interaction_remote_datasource.dart';
import 'package:reevo/features/interaction/data/repository/interaction_repository_impl.dart';
import 'package:reevo/features/interaction/domain/repository/interaction_repository.dart';
import 'package:reevo/features/interaction/domain/usecase/interaction_usecases.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_bloc.dart';
import 'package:reevo/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:reevo/features/notification/data/repository/notification_repository_impl.dart';
import 'package:reevo/features/notification/domain/repository/notification_repository.dart';
import 'package:reevo/features/notification/presentation/bloc/notification_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Token Storage Service
  getIt.registerSingleton<TokenStorageService>(
    TokenStorageService(getIt<SharedPreferences>()),
  );

  // Notification Service
  getIt.registerSingleton<NotificationService>(NotificationService());

  // WebSocket Service
  getIt.registerSingleton<WebSocketService>(WebSocketService());

  // Dio for Auth (without TokenInterceptor to avoid infinite loop)
  final authDio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      // Don't throw exception for error status codes (401, 403, 500, etc)
      // so we can handle them in the interceptor
      validateStatus: (status) => true,
    ),
  );
  getIt.registerSingleton<Dio>(authDio, instanceName: 'authDio');

  // Dio for API (with TokenInterceptor)
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  getIt.registerSingleton<Dio>(dio);

  getIt.registerSingleton<FeedEventService>(
    FeedEventService(dio: getIt<Dio>(), baseUrl: 'http://10.0.2.2:8080'),
  );

  // ─────────────────────────────────────────────
  // Auth Feature
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(
      dio: getIt<Dio>(instanceName: 'authDio'),
      baseUrl: 'http://10.0.2.2:8080',
    ),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<RegisterUseCase>(
    RegisterUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<RefreshTokenUseCase>(
    RefreshTokenUseCase(getIt<AuthRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      refreshTokenUseCase: getIt<RefreshTokenUseCase>(),
      tokenStorageService: getIt<TokenStorageService>(),
    ),
  );

  // Add Token Interceptor to Dio
  getIt<Dio>().interceptors.add(
    TokenInterceptor(
      tokenStorageService: getIt<TokenStorageService>(),
      authDio: getIt<Dio>(instanceName: 'authDio'),
      apiDio: getIt<Dio>(),
    ),
  );

  // ─────────────────────────────────────────────
  // User Feature
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerSingleton<UserRemoteDataSource>(
    UserRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl: 'http://10.0.2.2:8080',
    ),
  );

  // Repositories
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(remoteDataSource: getIt<UserRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerSingleton<UserBloc>(
    UserBloc(repository: getIt<UserRepository>()),
  );

  // ─────────────────────────────────────────────
  // Newfeed Feature
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerSingleton<VideoRemoteDataSource>(
    VideoRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl: 'http://10.0.2.2:8080', 
    ),
  );

  // Repositories
  getIt.registerSingleton<VideoRepository>(
    VideoRepositoryImpl(remoteDataSource: getIt<VideoRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<GetVideoFeedUseCase>(
    GetVideoFeedUseCase(getIt<VideoRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<VideoFeedBloc>(
    VideoFeedBloc(getVideoFeedUseCase: getIt<GetVideoFeedUseCase>()),
  );

  // ─────────────────────────────────────────────
  // Upload Feature
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerSingleton<UploadRemoteDataSource>(
    UploadRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl: 'http://10.0.2.2:8080', 
    ),
  );

  // Repositories
  getIt.registerSingleton<UploadRepository>(
    UploadRepositoryImpl(remoteDataSource: getIt<UploadRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<UploadVideoUseCase>(
    UploadVideoUseCase(getIt<UploadRepository>()),
  );

  // Cubits/BLoCs
  getIt.registerSingleton<UploadCubit>(
    UploadCubit(uploadVideoUseCase: getIt<UploadVideoUseCase>()),
  );

  // ─────────────────────────────────────────────
  // Interaction Feature
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerSingleton<InteractionRemoteDataSource>(
    InteractionRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl: 'http://10.0.2.2:8080',
    ),
  );

  // Repositories
  getIt.registerSingleton<InteractionRepository>(
    InteractionRepositoryImpl(remoteDataSource: getIt<InteractionRemoteDataSource>()),
  );

  // Use Cases
  getIt.registerSingleton<LikeVideoUseCase>(
    LikeVideoUseCase(getIt<InteractionRepository>()),
  );
  getIt.registerSingleton<UnlikeVideoUseCase>(
    UnlikeVideoUseCase(getIt<InteractionRepository>()),
  );
  getIt.registerSingleton<CommentVideoUseCase>(
    CommentVideoUseCase(getIt<InteractionRepository>()),
  );
  getIt.registerSingleton<GetCommentsUseCase>(
    GetCommentsUseCase(getIt<InteractionRepository>()),
  );
  getIt.registerSingleton<LikeCommentUseCase>(
    LikeCommentUseCase(getIt<InteractionRepository>()),
  );
  getIt.registerSingleton<UnlikeCommentUseCase>(
    UnlikeCommentUseCase(getIt<InteractionRepository>()),
  );
  getIt.registerSingleton<GetRepliesUseCase>(
    GetRepliesUseCase(getIt<InteractionRepository>()),
  );

  // BLoCs
  getIt.registerSingleton<InteractionBloc>(
    InteractionBloc(
      likeVideoUseCase: getIt<LikeVideoUseCase>(),
      unlikeVideoUseCase: getIt<UnlikeVideoUseCase>(),
      commentVideoUseCase: getIt<CommentVideoUseCase>(),
      getCommentsUseCase: getIt<GetCommentsUseCase>(),
      likeCommentUseCase: getIt<LikeCommentUseCase>(),
      unlikeCommentUseCase: getIt<UnlikeCommentUseCase>(),
      getRepliesUseCase: getIt<GetRepliesUseCase>(),
    ),
  );

  // ─────────────────────────────────────────────
  // Notification Feature
  // ─────────────────────────────────────────────

  // Data Sources
  getIt.registerSingleton<NotificationRemoteDataSource>(
    NotificationRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl: 'http://10.0.2.2:8080',
    ),
  );

  // Repositories
  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(remoteDataSource: getIt<NotificationRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerSingleton<NotificationBloc>(
    NotificationBloc(repository: getIt<NotificationRepository>()),
  );
}
