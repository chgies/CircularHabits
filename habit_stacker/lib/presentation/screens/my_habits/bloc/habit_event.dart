import 'package:equatable/equatable.dart';
import '../../../../data/models/habit.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object> get props => [];
}

class HabitsStarted extends HabitEvent {}

class HabitCompletionToggled extends HabitEvent {
  const HabitCompletionToggled(this.habit);

  final Habit habit;

  @override
  List<Object> get props => [habit];
}

class HabitDeleted extends HabitEvent {
  const HabitDeleted(this.habitId);

  final int habitId;

  @override
  List<Object> get props => [habitId];
}

class HabitImageUpdated extends HabitEvent {
  const HabitImageUpdated(this.habit, this.imagePath);

  final Habit habit;
  final String? imagePath;

  @override
  List<Object> get props => [habit, imagePath ?? ''];
}