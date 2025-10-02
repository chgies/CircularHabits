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

    final habit = await databaseService.getHabit(habitId);
    if (habit != null) {
      emit(state.copyWith(
        id: habit.id,
        name: habit.name,
        reward: habit.reward,
        identityNoun: habit.identityNoun,
        stackingOrder: habit.stackingOrder,
        selectedRoutine: habit.dailyRoutine,
        isEditing: true,
        creationDate: habit.creationDate,
        completionDates: habit.completionDates,
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

  void saveHabit() {
    final habit = Habit(
      id: state.id ?? DateTime.now().millisecondsSinceEpoch,
      name: state.name,
      reward: state.reward,
      identityNoun: state.identityNoun,
      creationDate: state.creationDate ?? DateTime.now(),
      completionDates: state.completionDates,
      stackingOrder: state.stackingOrder,
      dailyRoutine: state.selectedRoutine,
    );
    databaseService.saveHabit(habit);
  }
}