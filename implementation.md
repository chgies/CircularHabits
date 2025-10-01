Of course. Here is a detailed, step-by-step implementation paper for the "Habit Stacker" application, complete with integration tests for each primary user interaction as outlined in the Software Design Document.
Implementation Paper: Habit Stacker
This document provides a practical, step-by-step guide for implementing the "Habit Stacker" mobile application. It translates the design choices from the Software Design Document (SDD) into concrete code structure, state management logic, and a robust testing strategy.
1. Project Setup & Initial Configuration
The first step is to establish the project structure, add dependencies, and configure the core services.
1.1. Dependencies
Add the following dependencies to your pubspec.yaml file:
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3         # For BLoC and Cubit state management
  equatable: ^2.0.5            # Value equality for BLoC states/events
  isar: ^3.1.0                 # High-performance database
  isar_flutter_libs: ^3.1.0    # Isar bindings for Flutter
  go_router: ^10.0.0           # Declarative routing
  get_it: ^7.6.4               # Service locator for dependency injection
  rive: ^0.11.13               # For advanced animations

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:          # For on-device integration testing
    sdk: flutter
  bloc_test: ^9.1.4            # For testing BLoCs and Cubits
  mockito: ^5.4.2              # For creating mock objects
  build_runner: ^2.4.6         # For code generation (Isar)
  isar_generator: ^3.1.0       # Isar code generator

1.2. Directory Structure
Organize the lib folder to reflect the clean architecture:
lib/
├── core/
│   ├── services/
│   │   ├── database_service.dart      # Abstract database service
│   │   └── isar_service.dart          # Isar implementation
│   └── di_container.dart              # get_it service locator setup
├── data/
│   └── models/
│       ├── habit.dart
│       └── daily_routine.dart
├── presentation/
│   ├── screens/
│   │   ├── my_habits/
│   │   │   ├── my_habits_screen.dart
│   │   │   └── bloc/
│   │   │       ├── habit_bloc.dart
│   │   │       ├── habit_event.dart
│   │   │       └── habit_state.dart
│   │   ├── habit_creation/
│   │   │   ├── habit_creation_screen.dart
│   │   │   └── cubit/
│   │   │       ├── habit_creation_cubit.dart
│   │   │       └── habit_creation_state.dart
│   │   ├── ... (similar structure for other screens)
│   └── widgets/ # Reusable UI components
├── app_router.dart # go_router configuration
└── main.dart

1.3. Application Entry Point (main.dart)
Initialize the necessary services before the app runs.
// lib/main.dart
import 'package:flutter/material.dart';
import 'core/di_container.dart' as di;
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.setupLocator(); // Setup dependency injection
  runApp(const HabitStackerApp());
}

class HabitStackerApp extends StatelessWidget {
  const HabitStackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Habit Stacker',
      theme: ThemeData(
        // ... theme definition ...
      ),
      routerConfig: AppRouter.router,
    );
  }
}

2. Core Components Implementation
2.1. Data Models
Implement the data models as described in the SDD, adding the necessary Isar annotations. Run dart run build_runner build to generate the .g.dart files.
// lib/data/models/habit.dart
import 'package:isar/isar.dart';
import 'daily_routine.dart';

part 'habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement;
  late String name;
  late String reward;
  String? identityNoun;
  late DateTime creationDate;
  List<DateTime> completionDates = [];
  late String stackingOrder; // 'before' or 'after'

  final dailyRoutine = IsarLink<DailyRoutine>();
  
  // The isCompletedToday getter from the SDD remains unchanged.
  @Ignore()
  bool get isCompletedToday { /* ... */ }
}

2.2. Database Service
Define the abstract service and its Isar implementation.
// lib/core/services/database_service.dart
abstract class DatabaseService {
  Future<void> init();
  Stream<List<Habit>> watchAllHabits();
  Future<void> saveHabit(Habit habit);
  // ... other methods
}

// lib/core/services/isar_service.dart
class IsarService implements DatabaseService {
  late Isar _isar;

  @override
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [HabitSchema, DailyRoutineSchema],
      directory: dir.path,
    );
  }
  
  @override
  Stream<List<Habit>> watchAllHabits() {
    return _isar.habits.where().watch(fireImmediately: true);
  }
  
  @override
  Future<void> saveHabit(Habit habit) {
    return _isar.writeTxn(() => _isar.habits.put(habit));
  }
  
  // ... other method implementations
}

2.3. Dependency Injection (get_it)
Set up the service locator to provide the DatabaseService.
// lib/core/di_container.dart
import 'package:get_it/get_it.dart';
import 'services/database_service.dart';
import 'services/isar_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final isarService = IsarService();
  await isarService.init();
  sl.registerSingleton<DatabaseService>(isarService);
}

3. Screen Implementation & Integration Testing
This section details the build-out for each screen, including its state management and a corresponding integration test plan.
3.1. My Habits Screen (MyHabitsScreen)
User Interactions to Test:
 * View habits in a PageView.
 * Tap the "complete habit" button.
 * Tap the "+" button to navigate to the creation screen.
 * Tap the "-" button, confirm, and delete the current habit.
Implementation (HabitBloc):
 * Events: HabitsStarted, HabitCompletionToggled, HabitDeleted.
 * States: HabitsLoadInProgress, HabitsLoadSuccess, HabitsLoadFailure.
 * Logic: The HabitsStarted event subscribes to databaseService.watchAllHabits(). Other events call the relevant database service methods.
<!-- end list -->
// lib/presentation/screens/my_habits/my_habits_screen.dart
class MyHabitsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitBloc(databaseService: sl<DatabaseService>())
        ..add(HabitsStarted()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Habits'),
          actions: [
            IconButton(
              key: const Key('addHabitButton'),
              icon: Icon(Icons.add),
              onPressed: () => context.push('/create-habit'),
            ),
            // ... Delete button
          ],
        ),
        body: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitsLoadSuccess) {
              if (state.habits.isEmpty) {
                return Center(child: Text('Add a habit to get started!'));
              }
              return PageView.builder(
                // ... build pages from state.habits
              );
            }
            // ... handle loading and error states
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Integration Tests (integration_test/my_habits_test.dart):
We use a MockDatabaseService and register it with get_it during test setup to isolate the UI and BLoC from the actual database.
// Mock setup
class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    // Override the singleton registration for testing
    sl.registerSingleton<DatabaseService>(mockDatabaseService);
  });
  
  integrationTest('tapping add button navigates to creation screen', (tester) async {
    // Arrange
    when(mockDatabaseService.watchAllHabits()).thenAnswer((_) => Stream.value([]));
    await tester.pumpWidget(HabitStackerApp());
    await tester.pumpAndSettle();
    
    // Act
    await tester.tap(find.byKey(const Key('addHabitButton')));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('Define Your Habit'), findsOneWidget); // Title of creation screen
  });

  integrationTest('tapping complete button toggles habit and calls service', (tester) async {
    // Arrange
    final habit = Habit()..name = 'Read one page'..completionDates = [];
    when(mockDatabaseService.watchAllHabits()).thenAnswer((_) => Stream.value([habit]));
    await tester.pumpWidget(HabitStackerApp());
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byKey(const Key('completeHabitButton_1'))); // Assuming key is based on habit ID
    await tester.pumpAndSettle();

    // Assert
    // 1. Verify the UI updated (e.g., button color changed)
    // 2. Verify the correct method was called on the mock service.
    verify(mockDatabaseService.saveHabit(any)).called(1);
  });
  
  // ... similar tests for deleting and swiping
}

3.2. Habit Creation/Editing Screen
User Interactions to Test:
 * Progress through the stepper by filling in fields and tapping "Continue".
 * Tap "Save Habit" on the final step.
Implementation (HabitCreationCubit):
 * State: HabitCreationState contains currentStep and the Habit object being built.
 * Methods: stepContinued, stepCancelled, habitNameChanged, rewardChanged, etc. Each method emits a new state with the updated values.
<!-- end list -->
// lib/presentation/screens/habit_creation/habit_creation_screen.dart
class HabitCreationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HabitCreationCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text('Create Habit')),
        body: BlocBuilder<HabitCreationCubit, HabitCreationState>(
          builder: (context, state) {
            return Stepper(
              currentStep: state.currentStep,
              onStepContinue: () => context.read<HabitCreationCubit>().stepContinued(),
              // ... other stepper logic
              steps: [
                Step(
                  title: Text('Define Your Habit'),
                  content: TextFormField(
                    onChanged: (value) => context.read<HabitCreationCubit>().habitNameChanged(value),
                  ),
                ),
                // ... other steps
              ],
            );
          },
        ),
      ),
    );
  }
}

Integration Tests (integration_test/habit_creation_test.dart):
integrationTest('completing all steps and saving calls database service', (tester) async {
    // Arrange: Navigate to the creation screen
    // ...

    // Act: Fill out all fields in the stepper
    await tester.enterText(find.byType(TextFormField).first, 'Read a book');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    
    // ... interact with dropdowns, text fields for all steps ...

    // Find and tap the save button on the final step
    await tester.tap(find.text('Save Habit'));
    await tester.pumpAndSettle();
    
    // Assert
    // 1. Verify navigation back to the My Habits screen
    expect(find.text('My Habits'), findsOneWidget);
    
    // 2. Verify the database service was called with the correct data
    final captured = verify(mockDatabaseService.saveHabit(captureAny)).captured;
    final Habit savedHabit = captured.first;
    expect(savedHabit.name, 'Read a book');
});

3.3. Daily Routines Screen (DailyRoutinesScreen)
User Interactions to Test:
 * View the list of routines.
 * Tap "+" to add a routine.
 * Swipe to delete a routine.
 * Drag and drop to reorder routines.
Implementation (RoutineCubit):
 * State: RoutineState which holds List<DailyRoutine>.
 * Methods: loadRoutines, addRoutine, deleteRoutine, reorderRoutines.
Integration Tests (integration_test/daily_routines_test.dart):
The most interesting test here is for reordering.
integrationTest('dragging and dropping a routine updates its order', (tester) async {
    // Arrange
    final routines = [
      DailyRoutine()..name = 'Morning Coffee'..order = 0,
      DailyRoutine()..name = 'Brush Teeth'..order = 1,
    ];
    when(mockDatabaseService.watchAllRoutines()).thenAnswer((_) => Stream.value(routines));
    await tester.pumpWidget(HabitStackerApp());
    // ... navigate to routines screen
    await tester.pumpAndSettle();

    // Act
    final firstRoutineFinder = find.text('Morning Coffee');
    final secondRoutineFinder = find.text('Brush Teeth');
    // Simulate dragging the first item down past the second one
    await tester.drag(firstRoutineFinder, const Offset(0.0, 100.0));
    await tester.pumpAndSettle();
    
    // Assert
    // 1. Verify the order was updated in the database service call
    final captured = verify(mockDatabaseService.saveAllRoutines(captureAny)).captured;
    final List<DailyRoutine> updatedRoutines = captured.first;
    expect(updatedRoutines[0].name, 'Brush Teeth');
    expect(updatedRoutines[0].order, 0);
    expect(updatedRoutines[1].name, 'Morning Coffee');
    expect(updatedRoutines[1].order, 1);
});

3.4. Statistics Screen (StatisticsScreen)
User Interactions to Test:
 * View statistics for a habit with a custom identityNoun.
 * View statistics for a habit without a custom identityNoun (verifies fallback logic).
Implementation (StatsCubit):
 * State: StatsState holding List<Habit>.
 * Methods: loadStats.
Integration Tests (integration_test/statistics_test.dart):
integrationTest('displays custom and default identity nouns correctly', (tester) async {
    // Arrange
    final habits = [
      Habit()
        ..name = 'Read'
        ..identityNoun = 'a Reader'
        ..completionDates = [DateTime.now(), DateTime.now().subtract(Duration(days: 1))],
      Habit()
        ..name = 'Code'
        ..identityNoun = null // No custom noun
        ..completionDates = [DateTime.now()],
    ];
    when(mockDatabaseService.watchAllHabits()).thenAnswer((_) => Stream.value(habits));
    await tester.pumpWidget(HabitStackerApp());
    // ... navigate to statistics screen
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('You have shown your identity as a Reader for 2 days. Congratulations!'), findsOneWidget);
    expect(find.text('You have shown your identity as a Learner for 1 days. Congratulations!'), findsOneWidget);
});

4. Conclusion
This implementation plan provides a clear, test-driven path to building the Habit Stacker application. By separating concerns (UI, State, Data) and leveraging dependency injection, each component can be developed and tested in isolation before being verified with end-to-end integration tests. This methodology ensures a high-quality, maintainable, and robust final product that adheres to the principles outlined in the Software Design Document.
