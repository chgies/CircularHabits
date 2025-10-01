import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/database_service.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit({required this.databaseService}) : super(StatsLoadInProgress()) {
    _habitsSubscription = databaseService.watchAllHabits().listen((habits) {
      emit(StatsLoadSuccess(habits));
    });
  }

  final DatabaseService databaseService;
  StreamSubscription? _habitsSubscription;

  @override
  Future<void> close() {
    _habitsSubscription?.cancel();
    return super.close();
  }
}