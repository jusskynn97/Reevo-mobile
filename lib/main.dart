import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reevo/app/routes/app_router.dart';
import 'package:reevo/app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // Initialize other services here if needed
  //...
  // await init();
  runApp(const ReevoApp());
}

class ReevoApp extends StatelessWidget {
  const ReevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter().router,
    );
  }

}
