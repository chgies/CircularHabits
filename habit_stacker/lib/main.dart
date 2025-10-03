import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di_container.dart' as di;
import 'core/services/database_service.dart';
import 'presentation/screens/my_habits/bloc/habit_bloc.dart';
import 'presentation/screens/my_habits/bloc/habit_event.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.setupLocator(); // Setup dependency injection
  runApp(const HabitStackerApp());
}

class HabitStackerApp extends StatelessWidget {
  const HabitStackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitBloc(databaseService: di.sl<DatabaseService>())
        ..add(HabitsStarted()),
      child: MaterialApp.router(
        title: 'Habit Stacker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}