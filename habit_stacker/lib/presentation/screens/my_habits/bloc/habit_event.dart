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