import 'package:go_router/go_router.dart';
import 'package:reevo/features/test_page/presentation/page/test_page.dart';
import 'routes.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  late final GoRouter router = GoRouter(
    initialLocation: Routes.test, //Default: Onboarding page
    routes: [
      GoRoute(
        path: Routes.test,
        builder: (_, __) => const TestPage(),
      ),
    ],
  );

}