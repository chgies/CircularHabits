import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_service.dart';
import '../../../../data/models/daily_routine.dart';
import 'routine_state.dart';

class RoutineCubit extends Cubit<RoutineState> {
  RoutineCubit({required this.databaseService}) : super(RoutinesLoadInProgress()) {
    _routinesSubscription = databaseService.watchAllRoutines().listen((routines) {
      emit(RoutinesLoadSuccess(routines));
    });
  }

  final DatabaseService databaseService;
  StreamSubscription<List<DailyRoutine>>? _routinesSubscription;

  @override
  Future<void> close() {
    _routinesSubscription?.cancel();
    return super.close();
  }

  void addRoutine(String name) {
    if (state is RoutinesLoadSuccess) {
      final routines = (state as RoutinesLoadSuccess).routines;
      final newRoutine = DailyRoutine(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        order: routines.length,
      );
      final updatedRoutines = List<DailyRoutine>.from(routines)..add(newRoutine);
      databaseService.saveAllRoutines(updatedRoutines);
    }
  }

  void deleteRoutine(int routineId) {
    if (state is RoutinesLoadSuccess) {
      final routines = (state as RoutinesLoadSuccess).routines;
      final updatedRoutines = routines.where((r) => r.id != routineId).toList();
      // Re-order the remaining routines
      for (var i = 0; i < updatedRoutines.length; i++) {
        // This is a simplified re-ordering. A real implementation might need more robust logic.
        // updatedRoutines[i] = updatedRoutines[i].copyWith(order: i);
      }
      databaseService.saveAllRoutines(updatedRoutines);
    }
  }

  void reorderRoutines(int oldIndex, int newIndex) {
    if (state is RoutinesLoadSuccess) {
      final routines = List<DailyRoutine>.from((state as RoutinesLoadSuccess).routines);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final DailyRoutine item = routines.removeAt(oldIndex);
      routines.insert(newIndex, item);

      // Create a new list with updated order values
      final List<DailyRoutine> updatedRoutines = [];
      for (var i = 0; i < routines.length; i++) {
        final routine = routines[i];
        // This is a simplified re-ordering. A real implementation might need more robust logic.
        // updatedRoutines.add(routine.copyWith(order: i));
        updatedRoutines.add(DailyRoutine(id: routine.id, name: routine.name, order: i));
      }
      databaseService.saveAllRoutines(updatedRoutines);
    }
  }
}