import '../../data/models/habit.dart';
import '../../data/models/daily_routine.dart';

abstract class DatabaseService {
  Stream<List<Habit>> watchAllHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> deleteHabit(int habitId);

  Stream<List<DailyRoutine>> watchAllRoutines();
  Future<void> saveAllRoutines(List<DailyRoutine> routines);
  Future<void> deleteRoutine(int routineId);
}