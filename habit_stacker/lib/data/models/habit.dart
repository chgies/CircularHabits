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
    this.imagePath,
  });

  final int id;
  final String name;
  final String reward;
  final String? identityNoun;
  final DateTime creationDate;
  final List<DateTime> completionDates;
  final String stackingOrder; // 'before' or 'after'
  final DailyRoutine? dailyRoutine;
  final String? imagePath;

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

  Habit copyWith({
    int? id,
    String? name,
    String? reward,
    String? identityNoun,
    DateTime? creationDate,
    List<DateTime>? completionDates,
    String? stackingOrder,
    DailyRoutine? dailyRoutine,
    String? imagePath,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      identityNoun: identityNoun ?? this.identityNoun,
      creationDate: creationDate ?? this.creationDate,
      completionDates: completionDates ?? this.completionDates,
      stackingOrder: stackingOrder ?? this.stackingOrder,
      dailyRoutine: dailyRoutine ?? this.dailyRoutine,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}