import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di_container.dart' as di;
import '../../../core/services/database_service.dart';
import 'bloc/habit_bloc.dart';
import 'bloc/habit_event.dart';
import 'bloc/habit_state.dart';

class MyHabitsScreen extends StatelessWidget {
  const MyHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitBloc(databaseService: di.sl<DatabaseService>())
        ..add(HabitsStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Habits'),
          actions: [
            IconButton(
              key: const Key('routinesButton'),
              icon: const Icon(Icons.list_alt),
              tooltip: 'Daily Routines',
              onPressed: () => context.push('/routines'),
            ),
            IconButton(
              key: const Key('statsButton'),
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistics',
              onPressed: () => context.push('/stats'),
            ),
            IconButton(
              key: const Key('addHabitButton'),
              icon: const Icon(Icons.add),
              tooltip: 'Add Habit',
              onPressed: () => context.push('/create-habit'),
            ),
          ],
        ),
        body: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitsLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HabitsLoadSuccess) {
              if (state.habits.isEmpty) {
                return const Center(child: Text('Add a habit to get started!'));
              }
              return HabitPageView(state: state);
            } else if (state is HabitsLoadFailure) {
              return const Center(child: Text('Failed to load habits.'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class HabitPageView extends StatefulWidget {
  const HabitPageView({super.key, required this.state});
  final HabitsLoadSuccess state;

  @override
  State<HabitPageView> createState() => _HabitPageViewState();
}

class _HabitPageViewState extends State<HabitPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = widget.state.habits;
    return Column(
      children: [
        if (habits.isNotEmpty)
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              key: Key('deleteHabitButton_${habits[_currentPage].id}'),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete Habit'),
                      content: Text('Are you sure you want to delete "${habits[_currentPage].name}"?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            context.read<HabitBloc>().add(HabitDeleted(habits[_currentPage].id));
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(habit.name, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Text('Reward: ${habit.reward}'),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      key: Key('completeHabitButton_${habit.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habit.isCompletedToday ? Colors.green : null,
                      ),
                      onPressed: () {
                        context.read<HabitBloc>().add(HabitCompletionToggled(habit));
                      },
                      child: Text(habit.isCompletedToday ? 'Completed!' : 'Complete Habit'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}