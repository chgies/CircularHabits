import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di_container.dart' as di;
import '../../../core/services/database_service.dart';
import '../../../data/models/habit.dart';
import '../../widgets/habit_photo_picker.dart';
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
              key: const Key('habitsListButton'),
              icon: const Icon(Icons.list),
              tooltip: 'Habits List',
              onPressed: () {
                _showHabitsList(context);
              },
            ),
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

  void _showHabitsList(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<HabitBloc>(),
          child: const HabitsListDialog(),
        );
      },
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
  bool _isJumping = false; // Flag to prevent re-entrant jumps

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null) {
        final roundedPage = page.round();
        if (roundedPage != _currentPage) {
          setState(() {
            _currentPage = roundedPage;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(HabitPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When habits list changes (e.g., deletion), ensure current page is within bounds
    final habitsLength = widget.state.habits.length;
    if (habitsLength > 0 && _currentPage >= habitsLength) {
      // Jump to the last valid page without triggering animations
      final newPage = habitsLength - 1;
      _currentPage = newPage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(newPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNextHabit() {
    final habits = widget.state.habits;
    if (habits.isEmpty) return;
    
    final nextPage = (_currentPage + 1) % habits.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Handle circular scroll at boundaries
              if (notification is ScrollEndNotification && !_isJumping) {
                final metrics = notification.metrics;
                final habits = widget.state.habits;
                
                // Only handle circular scroll if we have more than one habit
                if (habits.length <= 1) return false;
                
                // If at the last page and scrolling down, jump to first
                if (_currentPage == habits.length - 1 && 
                    metrics.pixels >= metrics.maxScrollExtent) {
                  _isJumping = true;
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _pageController.jumpToPage(0);
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _isJumping = false;
                      });
                    }
                  });
                }
                // If at the first page and scrolling up, jump to last
                else if (_currentPage == 0 && 
                         metrics.pixels <= metrics.minScrollExtent) {
                  _isJumping = true;
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _pageController.jumpToPage(habits.length - 1);
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _isJumping = false;
                      });
                    }
                  });
                }
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return SwipeableHabitCard(
                  habit: habit,
                  onComplete: () {
                    context.read<HabitBloc>().add(HabitCompletionToggled(habit));
                    _navigateToNextHabit();
                  },
                  onEdit: () {
                    context.push('/edit-habit/${habit.id}');
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SwipeableHabitCard extends StatefulWidget {
  const SwipeableHabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onEdit,
  });

  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

  @override
  State<SwipeableHabitCard> createState() => _SwipeableHabitCardState();
}

class _SwipeableHabitCardState extends State<SwipeableHabitCard> {
  double _dragExtent = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final threshold = MediaQuery.of(context).size.width / 3;
    final progress = (_dragExtent.abs() / threshold).clamp(0.0, 1.0);
    
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.primaryDelta!;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragExtent.abs() >= threshold) {
          if (_dragExtent > 0) {
            // Swiped right - complete habit
            widget.onComplete();
          } else {
            // Swiped left - edit habit
            widget.onEdit();
          }
        }
        setState(() {
          _dragExtent = 0;
          _isDragging = false;
        });
      },
      child: Stack(
        children: [
          // Background with color and icon
          if (_isDragging && _dragExtent != 0)
            Positioned.fill(
              child: Container(
                color: _dragExtent > 0
                    ? Colors.green.withOpacity(progress)
                    : Colors.yellow.withOpacity(progress),
                child: Align(
                  alignment: _dragExtent > 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Icon(
                      _dragExtent > 0 ? Icons.check : Icons.settings,
                      color: Colors.white.withOpacity(progress),
                      size: 48 * progress,
                    ),
                  ),
                ),
              ),
            ),
          // Main habit card
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: _buildHabitCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          HabitPhotoPicker(
            key: Key('habitPhotoPicker_${widget.habit.id}'),
            imagePath: widget.habit.imagePath,
            onImageSelected: (imagePath) {
              context.read<HabitBloc>().add(
                HabitImageUpdated(widget.habit, imagePath),
              );
            },
          ),
          const SizedBox(height: 16),
          if (widget.habit.dailyRoutine != null) ...[
            Text(
              '${widget.habit.stackingOrder} in ${widget.habit.dailyRoutine!.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
          ],
          Text(widget.habit.name,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('Reward: ${widget.habit.reward}'),
          const SizedBox(height: 32),
          ElevatedButton(
            key: Key('completeHabitButton_${widget.habit.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.habit.isCompletedToday ? Colors.green : null,
            ),
            onPressed: () {
              context
                  .read<HabitBloc>()
                  .add(HabitCompletionToggled(widget.habit));
            },
            child: Text(widget.habit.isCompletedToday
                ? 'Completed!'
                : 'Complete Habit'),
          ),
          const SizedBox(height: 16),
          Text(
            'Swipe right to complete • Swipe left to edit • Swipe up/down to navigate',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HabitsListDialog extends StatelessWidget {
  const HabitsListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state is HabitsLoadSuccess) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('My Habits'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.habits.length,
                    itemBuilder: (context, index) {
                      final habit = state.habits[index];
                      return ListTile(
                        leading: IconButton(
                          key: Key('toggleHabitButton_${habit.id}'),
                          icon: Icon(
                            habit.isCompletedToday
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: habit.isCompletedToday
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () {
                            context
                                .read<HabitBloc>()
                                .add(HabitCompletionToggled(habit));
                          },
                        ),
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            color: habit.isCompletedToday
                                ? Colors.green
                                : Colors.black,
                            fontWeight: habit.isCompletedToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(habit.reward),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}