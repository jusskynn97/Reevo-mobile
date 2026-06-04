import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reevo/core/router/app_router.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/notification_service.dart';
import 'package:reevo/core/services/websocket_service.dart';
import 'package:reevo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';
import 'package:reevo/features/user/presentation/bloc/user_bloc.dart';
import 'package:reevo/features/interaction/presentation/bloc/interaction_bloc.dart';
import 'package:reevo/features/notification/presentation/bloc/notification_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires google-services.json on Android / GoogleService-Info.plist on iOS)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await setupServiceLocator();
  
  // Initialize Notification Service
  try {
    await GetIt.instance<NotificationService>().initialize();
  } catch (e) {
    debugPrint('Notification Service initialization failed: $e');
  }
  
  // Initialize WebSocket Service
  try {
    GetIt.instance<WebSocketService>().connect();
  } catch (e) {
    debugPrint('WebSocket Service initialization failed: $e');
  }

  runApp(const ReevoApp());
}

class ReevoApp extends StatelessWidget {
  const ReevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => GetIt.instance<AuthBloc>()
              ..add(const AuthCheckStatusEvent()),
          ),
          BlocProvider<VideoFeedBloc>(
            create: (context) => GetIt.instance<VideoFeedBloc>(),
          ),
          BlocProvider<UserBloc>(
            create: (context) => GetIt.instance<UserBloc>(),
          ),
          BlocProvider<InteractionBloc>(
            create: (context) => GetIt.instance<InteractionBloc>(),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => GetIt.instance<NotificationBloc>(),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
