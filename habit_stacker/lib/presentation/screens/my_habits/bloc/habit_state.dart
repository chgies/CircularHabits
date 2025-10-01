import 'package:equatable/equatable.dart';
import '../../../../data/models/habit.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object> get props => [];
}

class HabitsLoadInProgress extends HabitState {}

class HabitsLoadSuccess extends HabitState {
  const HabitsLoadSuccess([this.habits = const []]);

  final List<Habit> habits;

  @override
  List<Object> get props => [habits];
}

class HabitsLoadFailure extends HabitState {}