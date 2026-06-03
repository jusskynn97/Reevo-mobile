import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reevo/core/presentation/pages/main_shell_page.dart';
import 'package:reevo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reevo/features/auth/presentation/pages/login_page.dart';
import 'package:reevo/features/auth/presentation/pages/register_page.dart';
import 'package:reevo/features/newfeed/presentation/page/newfeed_page.dart';
import 'package:reevo/features/newfeed/presentation/page/video_detail_page.dart';
import 'package:reevo/features/notification/presentation/pages/notification_page.dart';
import 'package:reevo/features/placeholder/presentation/pages/placeholder_page.dart';
import 'package:reevo/features/upload/presentation/page/upload_video_page.dart';
import 'package:reevo/features/user/presentation/pages/profile_page.dart';
import 'package:reevo/features/watch_together/presentation/pages/discover_page.dart';
import 'package:reevo/features/watch_together/presentation/pages/room_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isOnAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // If not logged in and trying to access protected routes
    if (!isLoggedIn &&
        !isOnAuthPage &&
        state.matchedLocation != '/' &&
        state.matchedLocation != '/discover') {
      return '/login';
    }

    // If logged in and trying to access auth pages, go home
    if (isLoggedIn && isOnAuthPage) {
      return '/';
    }

    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const RegisterPage(),
      ),
    ),

    // Upload route - full screen modal (no bottom bar)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/upload',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const UploadVideoPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    ),

    // Video detail route
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/video/:videoId',
      builder: (context, state) {
        final videoId = state.pathParameters['videoId']!;
        return VideoDetailPage(videoId: videoId);
      },
    ),
    // User profile route
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/user/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return ProfilePage(userId: userId);
      },
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellPage(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home / Newfeed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const NewfeedPage(),
            ),
          ],
        ),

        // Branch 1: Discover
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverPage(),
            ),
          ],
        ),

        // Branch 2: Add (placeholder, actual upload opens as modal)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/add',
              builder: (context, state) => const PlaceholderPage(title: 'Add'),
            ),
          ],
        ),

        // Branch 3: Activity / Notifications
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationPage(),
            ),
          ],
        ),

        // Branch 4: Profile (protected)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  return NoTransitionPage(
                    child: const ProfilePage(),
                  );
                }
                return NoTransitionPage(
                  child: const LoginPage(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

