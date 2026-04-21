import 'package:flutter/material.dart';
import 'package:reevo/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReevoApp());
}

class ReevoApp extends StatelessWidget {
  const ReevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
