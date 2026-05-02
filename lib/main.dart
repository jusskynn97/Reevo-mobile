import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reevo/core/router/app_router.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/features/newfeed/presentation/bloc/video_feed_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const ReevoApp());
}

class ReevoApp extends StatelessWidget {
  const ReevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoFeedBloc>(
          create: (context) => GetIt.instance<VideoFeedBloc>(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
