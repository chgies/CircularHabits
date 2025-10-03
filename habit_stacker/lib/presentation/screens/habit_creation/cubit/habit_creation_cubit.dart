import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_service.dart';
import '../../../../data/models/habit.dart';
import 'habit_creation_state.dart';

class HabitCreationCubit extends Cubit<HabitCreationState> {
  HabitCreationCubit({required this.databaseService})
      : super(const HabitCreationState()) {
    _loadRoutines();
  }

  final DatabaseService databaseService;

  Future<void> loadHabitForEdit(int? habitId) async {
    if (habitId == null) return;

    final habits = await databaseService.watchAllHabits().first;
    final habit = habits.where((habit) => habit.id == habitId);

    if (habit.isNotEmpty) {
      emit(state.copyWith(
        id: habit.first.id,
        name: habit.first.name,
        reward: habit.first.reward,
        identityNoun: habit.first.identityNoun,
        stackingOrder: habit.first.stackingOrder,
        selectedRoutine: habit.first.dailyRoutine,
        isEditing: true,
        creationDate: habit.first.creationDate,
        completionDates: habit.first.completionDates,
        imagePath: habit.first.imagePath,
      ));
    }
  }

  void _loadRoutines() {
    databaseService.watchAllRoutines().first.then((routines) {
      emit(state.copyWith(routines: routines));
    });
  }

  void stepContinued() {
    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void stepCancelled() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void habitNameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void rewardChanged(String reward) {
    emit(state.copyWith(reward: reward));
  }

  void identityNounChanged(String identityNoun) {
    emit(state.copyWith(identityNoun: identityNoun));
  }

  void stackingOrderChanged(String? stackingOrder) {
    if (stackingOrder != null) {
      emit(state.copyWith(stackingOrder: stackingOrder));
    }
  }

  void routineSelected(dynamic routine) {
    emit(state.copyWith(selectedRoutine: routine));
  }

  void imagePathChanged(String? imagePath) {
    emit(state.copyWith(imagePath: imagePath));
  }

  void saveHabit() {
    final habit = Habit(
      id: state.id ?? DateTime.now().millisecondsSinceEpoch,
      name: state.name,
      reward: state.reward,
      identityNoun: state.identityNoun,
      creationDate: state.creationDate ?? DateTime.now(),
      completionDates: state.completionDates,
      stackingOrder: state.stackingOrder,
      dailyRoutineId: state.selectedRoutine?.id,
      imagePath: state.imagePath,
    )..dailyRoutine = state.selectedRoutine;
    databaseService.saveHabit(habit);
  }
}