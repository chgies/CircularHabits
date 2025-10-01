import 'package:equatable/equatable.dart';
import '../../../../data/models/daily_routine.dart';

abstract class RoutineState extends Equatable {
  const RoutineState();

  @override
  List<Object> get props => [];
}

class RoutinesLoadInProgress extends RoutineState {}

class RoutinesLoadSuccess extends RoutineState {
  const RoutinesLoadSuccess([this.routines = const []]);

  final List<DailyRoutine> routines;

  @override
  List<Object> get props => [routines];
}

class RoutinesLoadFailure extends RoutineState {}