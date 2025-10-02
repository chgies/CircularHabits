import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_service.dart';
import 'habit_event.dart';
import 'habit_state.dart';
import '../../../../data/models/habit.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  HabitBloc({required this.databaseService}) : super(HabitsLoadInProgress()) {
    on<HabitsStarted>(_onHabitsStarted);
    on<HabitCompletionToggled>(_onHabitCompletionToggled);
    on<HabitDeleted>(_onHabitDeleted);
    on<_HabitsUpdated>(_onHabitsUpdated);
  }

  final DatabaseService databaseService;
  StreamSubscription<List<Habit>>? _habitsSubscription;

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    return super.close();
  }

  void _onHabitsStarted(HabitsStarted event, Emitter<HabitState> emit) {
    emit(HabitsLoadInProgress());
    _habitsSubscription?.cancel();
    _habitsSubscription = databaseService.watchAllHabits().listen(
          (habits) => add(_HabitsUpdated(habits)),
          onError: (_) => emit(HabitsLoadFailure()),
        );
  }

  Future<void> _onHabitCompletionToggled(
    HabitCompletionToggled event,
    Emitter<HabitState> emit,
  ) async {
    final currentState = state;
    if (currentState is HabitsLoadSuccess) {
      final habit = event.habit;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      List<DateTime> updatedCompletionDates;

      if (habit.isCompletedToday) {
        // Remove today's completion
        updatedCompletionDates = habit.completionDates
            .where((date) =>
                date.year != today.year ||
                date.month != today.month ||
                date.day != today.day)
            .toList();
      } else {
        // Add today's completion
        updatedCompletionDates = List.from(habit.completionDates)..add(today);
      }

      final updatedHabit =
          habit.copyWith(completionDates: updatedCompletionDates);

      // Emit optimistic update immediately for instant UI feedback
      final updatedHabits = currentState.habits.map((h) {
        return h.id == updatedHabit.id ? updatedHabit : h;
      }).toList();
      emit(HabitsLoadSuccess(updatedHabits));

      try {
        await databaseService.saveHabit(updatedHabit);
        // The stream subscription will emit the updated state automatically
      } catch (_) {
        // Optionally handle error state
      }
    }
  }

  Future<void> _onHabitDeleted(
      HabitDeleted event, Emitter<HabitState> emit) async {
    final currentState = state;
    if (currentState is HabitsLoadSuccess) {
      // Emit optimistic update immediately for instant UI feedback
      final updatedHabits = currentState.habits.where((h) => h.id != event.habitId).toList();
      emit(HabitsLoadSuccess(updatedHabits));
      
      try {
        await databaseService.deleteHabit(event.habitId);
        // The stream subscription will emit the updated state automatically
      } catch (_) {
        // Optionally handle error state
      }
    }
  }

  void _onHabitsUpdated(_HabitsUpdated event, Emitter<HabitState> emit) {
    emit(HabitsLoadSuccess(event.habits));
  }
}

// Private event to push updated habits into the BLoC
class _HabitsUpdated extends HabitEvent {
  const _HabitsUpdated(this.habits);

  final List<Habit> habits;

  @override
  List<Object> get props => [habits];
}