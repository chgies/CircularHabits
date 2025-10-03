import 'dart:async';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';
import '../../data/models/habit.dart';
import '../../data/models/daily_routine.dart';

class IsarDatabaseService implements DatabaseService {
  static Isar? _isar;
  
  static Future<Isar> _getIsar() async {
    if (_isar != null) return _isar!;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [HabitSchema, DailyRoutineSchema],
      directory: dir.path,
    );
    
    return _isar!;
  }

  Future<void> initialize() async {
    final isar = await _getIsar();
    
    // Initialize with some default routines if database is empty
    final routineCount = await isar.dailyRoutines.count();
    if (routineCount == 0) {
      await isar.writeTxn(() async {
        await isar.dailyRoutines.putAll([
          DailyRoutine(name: 'Morning Coffee', order: 0),
          DailyRoutine(name: 'Evening Walk', order: 1),
        ]);
      });
    }
  }

  @override
  Future<void> deleteHabit(int habitId) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.habits.delete(habitId);
    });
  }

  @override
  Future<void> deleteRoutine(int routineId) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.dailyRoutines.delete(routineId);
    });
  }

  @override
  Future<void> saveAllRoutines(List<DailyRoutine> routines) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      // Clear existing routines
      await isar.dailyRoutines.clear();
      // Add new routines
      await isar.dailyRoutines.putAll(routines);
    });
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final isar = await _getIsar();
    await isar.writeTxn(() async {
      await isar.habits.put(habit);
    });
  }

  @override
  Stream<List<Habit>> watchAllHabits() async* {
    final isar = await _getIsar();
    
    yield* isar.habits.where().watch(fireImmediately: true).asyncMap((habits) async {
      // Refresh routines map
      final updatedRoutines = await isar.dailyRoutines.where().findAll();
      final updatedRoutineMap = {for (var r in updatedRoutines) r.id: r};
      
      // Populate dailyRoutine relationship
      for (var habit in habits) {
        if (habit.dailyRoutineId != null) {
          habit.dailyRoutine = updatedRoutineMap[habit.dailyRoutineId];
        }
      }
      return habits;
    });
  }

  @override
  Stream<List<DailyRoutine>> watchAllRoutines() async* {
    final isar = await _getIsar();
    yield* isar.dailyRoutines.where().watch(fireImmediately: true);
  }

  Future<void> dispose() async {
    await _isar?.close();
    _isar = null;
  }
}
