import 'package:isar_community/isar.dart';

part 'daily_routine.g.dart';

@collection
class DailyRoutine {
  DailyRoutine({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.order,
  });

  Id id;
  late String name;
  late int order;

  DailyRoutine copyWith({
    int? id,
    String? name,
    int? order,
  }) {
    return DailyRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }
}