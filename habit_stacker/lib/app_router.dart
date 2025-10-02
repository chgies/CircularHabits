import 'package:go_router/go_router.dart';
import 'presentation/screens/my_habits/my_habits_screen.dart';
import 'presentation/screens/habit_creation/habit_creation_screen.dart';
import 'presentation/screens/daily_routines/daily_routines_screen.dart';
import 'presentation/screens/statistics/statistics_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/habits',
    routes: [
      GoRoute(
        path: '/habits',
        builder: (context, state) => const MyHabitsScreen(),
      ),
      GoRoute(
        path: '/create-habit',
        builder: (context, state) => const HabitCreationScreen(),
      ),
      GoRoute(
        path: '/edit-habit/:id',
        builder: (context, state) {
          final habitId = int.parse(state.pathParameters['id']!);
          return HabitCreationScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/routines',
        builder: (context, state) => const DailyRoutinesScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatisticsScreen(),
      ),
    ],
  );
}