import 'package:equatable/equatable.dart';
import '../../../../data/models/daily_routine.dart';

class HabitCreationState extends Equatable {
  const HabitCreationState({
    this.id,
    this.currentStep = 0,
    this.name = '',
    this.reward = '',
    this.identityNoun,
    this.stackingOrder = 'after',
    this.selectedRoutine,
    this.routines = const [],
    this.isEditing = false,
    this.creationDate,
    this.completionDates = const [],
    this.imagePath,
  });

  final int? id;
  final int currentStep;
  final String name;
  final String reward;
  final String? identityNoun;
  final String stackingOrder;
  final DailyRoutine? selectedRoutine;
  final List<DailyRoutine> routines;
  final bool isEditing;
  final DateTime? creationDate;
  final List<DateTime> completionDates;
  final String? imagePath;

  HabitCreationState copyWith({
    int? id,
    int? currentStep,
    String? name,
    String? reward,
    String? identityNoun,
    String? stackingOrder,
    DailyRoutine? selectedRoutine,
    List<DailyRoutine>? routines,
    bool? isEditing,
    DateTime? creationDate,
    List<DateTime>? completionDates,
    String? imagePath,
  }) {
    return HabitCreationState(
      id: id ?? this.id,
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      identityNoun: identityNoun ?? this.identityNoun,
      stackingOrder: stackingOrder ?? this.stackingOrder,
      selectedRoutine: selectedRoutine ?? this.selectedRoutine,
      routines: routines ?? this.routines,
      isEditing: isEditing ?? this.isEditing,
      creationDate: creationDate ?? this.creationDate,
      completionDates: completionDates ?? this.completionDates,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        currentStep,
        name,
        reward,
        identityNoun,
        stackingOrder,
        selectedRoutine,
        routines,
        isEditing,
        creationDate,
        completionDates,
        imagePath,
      ];
}