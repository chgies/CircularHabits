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
  }

  final DatabaseService databaseService;
  StreamSubscription<List<Habit>>? _habitsSubscription;

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    return super.close();
  }

  void _onHabitsStarted(HabitsStarted event, Emitter<HabitState> emit) {
    _habitsSubscription?.cancel();
    _habitsSubscription = databaseService.watchAllHabits().listen(
          (habits) => add(_HabitsUpdated(habits)),
          onError: (_) => emit(HabitsLoadFailure()),
        );
  }

  void _onHabitCompletionToggled(
    HabitCompletionToggled event,
    Emitter<HabitState> emit,
  ) {
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

    final updatedHabit = habit.copyWith(completionDates: updatedCompletionDates);
    databaseService.saveHabit(updatedHabit);
  }

  void _onHabitDeleted(HabitDeleted event, Emitter<HabitState> emit) {
    databaseService.deleteHabit(event.habitId);
  }
}

// Private event to push updated habits into the BLoC
class _HabitsUpdated extends HabitEvent {
  const _HabitsUpdated(this.habits);

  final List<Habit> habits;
}

// Extend the BLoC to handle the private event
extension on HabitBloc {
  void _onHabitsUpdated(_HabitsUpdated event, Emitter<HabitState> emit) {
    emit(HabitsLoadSuccess(event.habits));
  }
}

// Add a copyWith method to Habit to make updates easier
extension HabitCopyWith on Habit {
  Habit copyWith({
    int? id,
    String? name,
    String? reward,
    String? identityNoun,
    DateTime? creationDate,
    List<DateTime>? completionDates,
    String? stackingOrder,
    DailyRoutine? dailyRoutine,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      identityNoun: identityNoun ?? this.identityNoun,
      creationDate: creationDate ?? this.creationDate,
      completionDates: completionDates ?? this.completionDates,
      stackingOrder: stackingOrder ?? this.stackingOrder,
      dailyRoutine: dailyRoutine ?? this.dailyRoutine,
    );
  }
}