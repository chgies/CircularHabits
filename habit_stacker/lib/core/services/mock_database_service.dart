import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'database_service.dart';
import '../../data/models/habit.dart';
import '../../data/models/daily_routine.dart';

class MockDatabaseService implements DatabaseService {
  MockDatabaseService() {
    // Initialize with some mock data
    final initialHabits = [
      Habit(
        id: 1,
        name: 'Read one page',
        reward: 'A piece of chocolate',
        creationDate: DateTime.now().subtract(const Duration(days: 5)),
        stackingOrder: 'after',
        dailyRoutine: _routines.first,
        completionDates: [
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now().subtract(const Duration(days: 3)),
        ]
      ),
      Habit(
        id: 2,
        name: 'Do 10 push-ups',
        reward: 'Watch an episode of a show',
        creationDate: DateTime.now().subtract(const Duration(days: 10)),
        stackingOrder: 'before',
        dailyRoutine: _routines.last,
      ),
    ];

    _habits.addAll(initialHabits);
    _habitsController.add(_habits);
    _routinesController.add(_routines);
  }

  final List<Habit> _habits = [];
  final List<DailyRoutine> _routines = [
    DailyRoutine(id: 1, name: 'Morning Coffee', order: 0),
    DailyRoutine(id: 2, name: 'Evening Walk', order: 1),
  ];

  // Use BehaviorSubject to provide the last emitted value to new listeners.
  final _habitsController = BehaviorSubject<List<Habit>>();
  final _routinesController = BehaviorSubject<List<DailyRoutine>>();

  @override
  Future<void> deleteHabit(int habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
    _habitsController.add(_habits);
  }

  @override
  Future<void> deleteRoutine(int routineId) async {
    _routines.removeWhere((routine) => routine.id == routineId);
    _routinesController.add(_routines);
  }

  @override
  Future<void> saveAllRoutines(List<DailyRoutine> routines) async {
    _routines
      ..clear()
      ..addAll(routines);
    _routinesController.add(_routines);
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    } else {
      // Create a new habit with a unique ID
      final newId = (_habits.isNotEmpty ? _habits.map((h) => h.id).reduce((a, b) => a > b ? a : b) : 0) + 1;
      _habits.add(habit.copyWith(id: newId));
    }
    _habitsController.add(_habits);
  }

  @override
  Stream<List<Habit>> watchAllHabits() {
    return _habitsController.stream;
  }

  @override
  Stream<List<DailyRoutine>> watchAllRoutines() {
    return _routinesController.stream;
  }
}