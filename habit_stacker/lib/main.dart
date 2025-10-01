import 'package:flutter/material.dart';
import 'core/di_container.dart' as di;
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  di.setupLocator(); // Setup dependency injection
  runApp(const HabitStackerApp());
}

class HabitStackerApp extends StatelessWidget {
  const HabitStackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Habit Stacker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: AppRouter.router,
    );
  }
}