import 'daily_routine.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.reward,
    this.identityNoun,
    required this.creationDate,
    this.completionDates = const [],
    required this.stackingOrder,
    this.dailyRoutine,
  });

  final int id;
  final String name;
  final String reward;
  final String? identityNoun;
  final DateTime creationDate;
  final List<DateTime> completionDates;
  final String stackingOrder; // 'before' or 'after'
  final DailyRoutine? dailyRoutine;

  bool get isCompletedToday {
    if (completionDates.isEmpty) {
      return false;
    }
    final today = DateTime.now();
    final lastCompletion = completionDates.last;
    return lastCompletion.year == today.year &&
        lastCompletion.month == today.month &&
        lastCompletion.day == today.day;
  }
}