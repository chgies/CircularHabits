import 'package:isar_community/isar.dart';
import 'daily_routine.dart';

part 'habit.g.dart';

@collection
class Habit {
  Habit({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.reward,
    this.identityNoun,
    required this.creationDate,
    this.completionDates = const [],
    required this.stackingOrder,
    this.dailyRoutineId,
    this.imagePath,
  });

  Id id;
  late String name;
  late String reward;
  String? identityNoun;
  late DateTime creationDate;
  List<DateTime> completionDates;
  late String stackingOrder; // 'before' or 'after'
  int? dailyRoutineId;
  String? imagePath;

  @ignore
  DailyRoutine? dailyRoutine;

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
    int? dailyRoutineId,
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
      dailyRoutineId: dailyRoutineId ?? this.dailyRoutineId,
      imagePath: imagePath ?? this.imagePath,
    )..dailyRoutine = dailyRoutine ?? this.dailyRoutine;
  }
}