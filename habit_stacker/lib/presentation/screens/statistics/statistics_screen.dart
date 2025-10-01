import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di_container.dart' as di;
import '../../../core/services/database_service.dart';
import 'cubit/stats_cubit.dart';
import 'cubit/stats_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StatsCubit(databaseService: di.sl<DatabaseService>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const StatisticsView(),
      ),
    );
  }
}

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsCubit, StatsState>(
      builder: (context, state) {
        if (state is StatsLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StatsLoadSuccess) {
          if (state.habits.isEmpty) {
            return const Center(
                child: Text('No habit data to show statistics.'));
          }
          return ListView.builder(
            itemCount: state.habits.length,
            itemBuilder: (context, index) {
              final habit = state.habits[index];
              final identity = (habit.identityNoun != null && habit.identityNoun!.isNotEmpty)
                  ? habit.identityNoun
                  : 'a Learner';
              final completionCount = habit.completionDates.length;
              final daysString = completionCount == 1 ? 'day' : 'days';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You have shown your identity as $identity for $completionCount $daysString. Congratulations!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              );
            },
          );
        } else if (state is StatsLoadFailure) {
          return const Center(child: Text('Failed to load statistics.'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}