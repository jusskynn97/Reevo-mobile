import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reevo/core/presentation/pages/main_shell_page.dart';
import 'package:reevo/features/newfeed/presentation/page/newfeed_page.dart';
import 'package:reevo/features/placeholder/presentation/pages/placeholder_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
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
              builder: (context, state) => const PlaceholderPage(title: 'Discover'),
            ),
          ],
        ),
        
        // Branch 2: Add
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/add',
              builder: (context, state) => const PlaceholderPage(title: 'Add'),
            ),
          ],
        ),
        
        // Branch 3: Rooms
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rooms',
              builder: (context, state) => const PlaceholderPage(title: 'Rooms'),
            ),
          ],
        ),
        
        // Branch 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const PlaceholderPage(title: 'Profile'),
            ),
          ],
        ),
      ],
    ),
  ],
);
