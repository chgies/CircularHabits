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
    final cubit = context.read<RoutineCubit>();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _AddRoutineDialog(cubit: cubit);
      },
    );
  }
}

class _AddRoutineDialog extends StatefulWidget {
  final RoutineCubit cubit;
  
  const _AddRoutineDialog({required this.cubit});
  
  @override
  State<_AddRoutineDialog> createState() => _AddRoutineDialogState();
}

class _AddRoutineDialogState extends State<_AddRoutineDialog> {
  final Map<String, List<String>> categorizedRoutines = {
    'Morning': [
      'Wake Up',
      'Turn Off Alarm',
      'Drink Water',
      'Stretch in Bed',
      'Make Bed',
      'Use Bathroom',
      'Brush Teeth',
      'Wash Face',
      'Shower',
      'Shave',
      'Apply Skincare',
      'Put on Moisturizer',
      'Style Hair',
      'Get Dressed',
      'Check Weather',
      'Morning Prayer/Meditation',
      'Read News',
      'Check Phone',
      'Make Coffee',
      'Drink Coffee',
      'Make Breakfast',
      'Eat Breakfast',
      'Take Vitamins',
      'Take Medication',
      'Feed Pets',
      'Walk Dog',
      'Pack Lunch',
      'Prepare Kids for School',
      'Review Daily Schedule',
      'Check Calendar',
      'Morning Exercise',
      'Yoga',
      'Morning Run',
      'Commute to Work',
    ],
    'Afternoon/Day': [
      'Morning Snack',
      'Mid-Morning Break',
      'Check Emails',
      'Attend Meetings',
      'Work on Projects',
      'Lunch Break',
      'Make Lunch',
      'Eat Lunch',
      'Afternoon Coffee',
      'Afternoon Tea',
      'Quick Walk',
      'Stretch Break',
      'Power Nap',
      'Afternoon Snack',
      'Pick Up Kids',
      'Homework Time',
      'After-School Activities',
      'Grocery Shopping',
      'Run Errands',
      'Gym Workout',
      'Sports Practice',
      'Commute Home',
    ],
    'Evening': [
      'Arrive Home',
      'Change Clothes',
      'Prepare Dinner',
      'Cook Dinner',
      'Set Table',
      'Eat Dinner',
      'Family Time',
      'Clear Table',
      'Wash Dishes',
      'Clean Kitchen',
      'Evening Walk',
      'Play with Kids',
      'Help with Homework',
      'Bath Time (Kids)',
      'Bedtime Story',
      'Put Kids to Bed',
      'Watch TV',
      'Read Book',
      'Hobby Time',
      'Video Games',
      'Social Media',
      'Call Family/Friends',
      'Evening Exercise',
      'Evening Yoga',
      'Meditation',
      'Journal Writing',
      'Plan Tomorrow',
      'Review Day',
    ],
    'Night/Bedtime': [
      'Evening Snack',
      'Drink Herbal Tea',
      'Prepare for Bed',
      'Shower/Bath',
      'Remove Makeup',
      'Brush Teeth',
      'Floss',
      'Apply Night Cream',
      'Put on Pajamas',
      'Set Out Tomorrow\'s Clothes',
      'Pack Bag for Tomorrow',
      'Lock Doors',
      'Turn Off Lights',
      'Set Alarm',
      'Charge Phone',
      'Read in Bed',
      'Listen to Podcast',
      'Relaxation Exercises',
      'Evening Prayer',
      'Gratitude Practice',
      'Go to Sleep',
    ],
    'Anytime/Flexible': [
      'Drink Water',
      'Take Medication',
      'Check Messages',
      'Social Media Break',
      'Stretch',
      'Deep Breathing',
      'Listen to Music',
      'Podcast Time',
      'Study/Learn',
      'Practice Instrument',
      'Creative Work',
      'Side Project',
      'Laundry',
      'Clean Room',
      'Organize Space',
      'Water Plants',
      'Self-Care',
      'Skin Care Routine',
      'Hair Care',
      'Nail Care',
    ],
  };

  final Set<String> selectedRoutines = {};
  final TextEditingController controller = TextEditingController();
  String selectedCategory = 'Morning';

  List<String> get allRoutines {
    final all = <String>[];
    categorizedRoutines.forEach((category, routines) {
      all.addAll(routines);
    });
    return all;
  }

  List<String> get currentRoutines {
    return categorizedRoutines[selectedCategory] ?? [];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = selectedRoutines.length == currentRoutines.length && currentRoutines.isNotEmpty;
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add New Routines',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(allSelected ? Icons.check_box : Icons.check_box_outline_blank),
                  tooltip: allSelected ? 'Deselect All' : 'Select All',
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        selectedRoutines.removeAll(currentRoutines);
                      } else {
                        selectedRoutines.addAll(currentRoutines);
                      }
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            // Counter
            Text(
              selectedRoutines.isEmpty
                  ? 'Select one or more routines:'
                  : '${selectedRoutines.length} routine${selectedRoutines.length > 1 ? 's' : ''} selected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: selectedRoutines.isEmpty ? FontWeight.normal : FontWeight.bold,
                color: selectedRoutines.isEmpty ? Colors.grey[600] : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            // Category tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categorizedRoutines.keys.length,
                itemBuilder: (context, index) {
                  final category = categorizedRoutines.keys.elementAt(index);
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Routine list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: currentRoutines.length,
                  itemBuilder: (context, index) {
                    final routine = currentRoutines[index];
                    final isSelected = selectedRoutines.contains(routine);
                    
                    return CheckboxListTile(
                      title: Text(routine),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedRoutines.add(routine);
                          } else {
                            selectedRoutines.remove(routine);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Custom routine input
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Or enter custom routine name",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.cubit.addRoutine(value);
                  controller.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "$value"'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (selectedRoutines.isNotEmpty)
                  TextButton(
                    child: const Text('Clear Selection'),
                    onPressed: () {
                      setState(() {
                        selectedRoutines.clear();
                      });
                    },
                  ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  child: Text(
                    selectedRoutines.isEmpty ? 'Done' : 'Add Selected (${selectedRoutines.length})',
                  ),
                  onPressed: () {
                    if (selectedRoutines.isNotEmpty) {
                      for (final routine in selectedRoutines) {
                        widget.cubit.addRoutine(routine);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${selectedRoutines.length} routine${selectedRoutines.length > 1 ? 's' : ''}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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