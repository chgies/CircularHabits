import 'package:equatable/equatable.dart';
import '../../../../data/models/habit.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsLoadInProgress extends StatsState {}

class StatsLoadSuccess extends StatsState {
  const StatsLoadSuccess([this.habits = const []]);

  final List<Habit> habits;

  @override
  List<Object> get props => [habits];
}

class StatsLoadFailure extends StatsState {}