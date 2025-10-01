import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di_container.dart' as di;
import '../../../core/services/database_service.dart';
import 'cubit/routine_cubit.dart';
import 'cubit/routine_state.dart';

class DailyRoutinesScreen extends StatelessWidget {
  const DailyRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RoutineCubit(databaseService: di.sl<DatabaseService>()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Routines'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const RoutinesList(),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _showAddRoutineDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showAddRoutineDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add New Routine'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Routine name"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<RoutineCubit>().addRoutine(controller.text);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class RoutinesList extends StatelessWidget {
  const RoutinesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutineCubit, RoutineState>(
      builder: (context, state) {
        if (state is RoutinesLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RoutinesLoadSuccess) {
          if (state.routines.isEmpty) {
            return const Center(
                child: Text('Add a routine to get started!'));
          }
          return ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              context
                  .read<RoutineCubit>()
                  .reorderRoutines(oldIndex, newIndex);
            },
            children: state.routines.map((routine) {
              return Dismissible(
                key: Key('routine_${routine.id}'),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  context.read<RoutineCubit>().deleteRoutine(routine.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${routine.name} deleted')),
                  );
                },
                child: ListTile(
                  title: Text(routine.name),
                  leading: const Icon(Icons.drag_handle),
                ),
              );
            }).toList(),
          );
        } else if (state is RoutinesLoadFailure) {
          return const Center(child: Text('Failed to load routines.'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}