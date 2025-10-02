import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di_container.dart' as di;
import '../../../core/services/database_service.dart';
import '../../../data/models/daily_routine.dart';
import 'cubit/habit_creation_cubit.dart';
import 'cubit/habit_creation_state.dart';

class HabitCreationScreen extends StatelessWidget {
  const HabitCreationScreen({super.key, this.habitId});
  final int? habitId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HabitCreationCubit(databaseService: di.sl<DatabaseService>())
            ..loadHabitForEdit(habitId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(habitId == null ? 'Define Your Habit' : 'Edit Habit'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: const HabitCreationStepper(),
      ),
    );
  }
}

class HabitCreationStepper extends StatelessWidget {
  const HabitCreationStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitCreationCubit, HabitCreationState>(
      builder: (context, state) {
        return Stepper(
          currentStep: state.currentStep,
          onStepContinue: () {
            if (state.currentStep < 2) {
              context.read<HabitCreationCubit>().stepContinued();
            } else {
              // This is the "Save" action on the last step
              context.read<HabitCreationCubit>().saveHabit();
              context.pop();
            }
          },
          onStepCancel: () {
            if (state.currentStep > 0) {
              context.read<HabitCreationCubit>().stepCancelled();
            } else {
              context.pop();
            }
          },
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(
                        state.currentStep == 2 ? 'SAVE HABIT' : 'CONTINUE'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK'),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Define Your Habit'),
              isActive: state.currentStep >= 0,
              state: state.currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: state.name,
                    decoration: const InputDecoration(labelText: 'Habit Name'),
                    onChanged: (value) => context
                        .read<HabitCreationCubit>()
                        .habitNameChanged(value),
                  ),
                  TextFormField(
                    initialValue: state.reward,
                    decoration: const InputDecoration(labelText: 'Reward'),
                    onChanged: (value) => context
                        .read<HabitCreationCubit>()
                        .rewardChanged(value),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Stack it'),
              isActive: state.currentStep >= 1,
              state: state.currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                children: <Widget>[
                  DropdownButtonFormField<DailyRoutine>(
                    value: state.selectedRoutine,
                    hint: const Text('Select a routine to stack with'),
                    items: state.routines.map((DailyRoutine routine) {
                      return DropdownMenuItem<DailyRoutine>(
                        value: routine,
                        child: Text(routine.name),
                      );
                    }).toList(),
                    onChanged: (routine) => context
                        .read<HabitCreationCubit>()
                        .routineSelected(routine),
                  ),
                  const SizedBox(height: 20),
                  const Text('When do you want to do this habit?'),
                  RadioListTile<String>(
                    title: const Text('Before the routine'),
                    value: 'before',
                    groupValue: state.stackingOrder,
                    onChanged: (value) => context
                        .read<HabitCreationCubit>()
                        .stackingOrderChanged(value),
                  ),
                  RadioListTile<String>(
                    title: const Text('After the routine'),
                    value: 'after',
                    groupValue: state.stackingOrder,
                    onChanged: (value) => context
                        .read<HabitCreationCubit>()
                        .stackingOrderChanged(value),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Shape your Identity'),
              isActive: state.currentStep >= 2,
              content: Column(
                children: <Widget>[
                  const Text(
                      'Every action you take is a vote for the type of person you wish to become. What identity are you building?'),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: state.identityNoun,
                    decoration: const InputDecoration(
                      labelText: 'I am a...',
                      hintText: 'e.g., "writer", "runner", "healthy person"',
                    ),
                    onChanged: (value) => context
                        .read<HabitCreationCubit>()
                        .identityNounChanged(value),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}