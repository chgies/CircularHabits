import 'package:equatable/equatable.dart';
import '../../../../data/models/habit.dart';
import '../../../../data/models/daily_routine.dart';

class HabitCreationState extends Equatable {
  const HabitCreationState({
    this.currentStep = 0,
    this.name = '',
    this.reward = '',
    this.identityNoun,
    this.stackingOrder = 'after',
    this.selectedRoutine,
    this.routines = const [],
  });

  final int currentStep;
  final String name;
  final String reward;
  final String? identityNoun;
  final String stackingOrder;
  final DailyRoutine? selectedRoutine;
  final List<DailyRoutine> routines;

  HabitCreationState copyWith({
    int? currentStep,
    String? name,
    String? reward,
    String? identityNoun,
    String? stackingOrder,
    DailyRoutine? selectedRoutine,
    List<DailyRoutine>? routines,
  }) {
    return HabitCreationState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      identityNoun: identityNoun ?? this.identityNoun,
      stackingOrder: stackingOrder ?? this.stackingOrder,
      selectedRoutine: selectedRoutine ?? this.selectedRoutine,
      routines: routines ?? this.routines,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        name,
        reward,
        identityNoun,
        stackingOrder,
        selectedRoutine,
        routines,
      ];
}