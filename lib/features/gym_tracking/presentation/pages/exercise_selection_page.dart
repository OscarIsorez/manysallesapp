import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_session.dart';
import '../bloc/exercise/exercise_bloc.dart';
import '../bloc/exercise/exercise_event.dart';
import '../bloc/exercise/exercise_state.dart';
import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_event.dart';
import '../bloc/session/session_state.dart';

class ExerciseSelectionPage extends StatefulWidget {
  final String gymId;
  const ExerciseSelectionPage({super.key, required this.gymId});

  @override
  State<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseBloc>().add(GetExercisesEvent());
    context.read<SessionBloc>().add(GetSessionsEvent());
  }

  void _showAddExerciseDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Exercise',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => const _AddExerciseDialog(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _showManageSessionDialog({ExerciseSession? existingSession}) {
    final exerciseState = context.read<ExerciseBloc>().state;
    if (exerciseState is! ExerciseLoaded || exerciseState.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Add exercises before creating a session'),
        ),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Manage Session',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => _ManageSessionDialog(
        exercises: exerciseState.exercises,
        existingSession: existingSession,
      ),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  Future<void> _confirmDeleteSession(ExerciseSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete session?'),
          content: Text(
            'Remove "${session.name}"? Exercises will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      context.read<SessionBloc>().add(
        DeleteSessionEvent(sessionId: session.id),
      );
    }
  }

  Future<void> _confirmDeleteExercise(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          title: const Text('Delete exercise?'),
          content: Text(
            'Are you sure you want to delete "${exercise.name}"?\n\n'
            'This will also delete ALL logged history and remove it from any workout sessions. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      context.read<ExerciseBloc>().add(
        DeleteExerciseEvent(exerciseId: exercise.id),
      );
    }
  }

  List<Exercise> _orderedExercises(
    List<Exercise> exercises,
    ExerciseSession? selectedSession,
  ) {
    if (selectedSession == null || selectedSession.exerciseIds.isEmpty) {
      return exercises;
    }

    final sessionIds = selectedSession.exerciseIds.toSet();
    final sessionExercises = <Exercise>[];
    final otherExercises = <Exercise>[];

    for (final exercise in exercises) {
      if (sessionIds.contains(exercise.id)) {
        sessionExercises.add(exercise);
      } else {
        otherExercises.add(exercise);
      }
    }

    sessionExercises.sort((a, b) {
      return selectedSession.exerciseIds
          .indexOf(a.id)
          .compareTo(selectedSession.exerciseIds.indexOf(b.id));
    });

    return [...sessionExercises, ...otherExercises];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda_outlined),
            tooltip: 'Manage sessions',
            onPressed: () => _showManageSessionDialog(),
          ),
        ],
      ),
      body: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, exerciseState) {
          return BlocBuilder<SessionBloc, SessionState>(
            builder: (context, sessionState) {
              if (exerciseState is ExerciseLoading ||
                  sessionState is SessionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (exerciseState is ExerciseError) {
                return Center(child: Text('Error: ${exerciseState.message}'));
              }

              if (exerciseState is! ExerciseLoaded) {
                return const Center(child: Text('Initializing...'));
              }

              final sessions = sessionState is SessionLoaded
                  ? sessionState.sessions
                  : <ExerciseSession>[];
              final selectedSession = sessionState is SessionLoaded
                  ? sessionState.selectedSession
                  : null;
              final selectedSessionId = sessionState is SessionLoaded
                  ? sessionState.selectedSessionId
                  : null;

              if (exerciseState.exercises.isEmpty) {
                return _EmptyExercisesView(onAdd: _showAddExerciseDialog);
              }

              final orderedExercises = _orderedExercises(
                exerciseState.exercises,
                selectedSession,
              );
              final sessionExerciseIds =
                  selectedSession?.exerciseIds.toSet() ?? <String>{};

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout sessions',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _SessionChip(
                                  label: 'All',
                                  selected: selectedSessionId == null,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context.read<SessionBloc>().add(
                                      const SelectSessionEvent(sessionId: null),
                                    );
                                  },
                                ),
                                ...sessions.map((session) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: _SessionChip(
                                      label: session.name,
                                      selected: selectedSessionId == session.id,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        context.read<SessionBloc>().add(
                                          SelectSessionEvent(
                                            sessionId: session.id,
                                          ),
                                        );
                                      },
                                      onLongPress: () =>
                                          _confirmDeleteSession(session),
                                    ),
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ActionChip(
                                    avatar: Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                    label: const Text('New'),
                                    onPressed: () => _showManageSessionDialog(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedSession != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${selectedSession.name} · '
                                  '${sessionExerciseIds.length} exercises',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                tooltip: 'Edit session',
                                onPressed: () => _showManageSessionDialog(
                                  existingSession: selectedSession,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    sliver: SliverList.separated(
                      itemCount: orderedExercises.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final exercise = orderedExercises[index];
                        final isInSession = sessionExerciseIds.contains(
                          exercise.id,
                        );
                        final showSessionHeader =
                            selectedSession != null &&
                            isInSession &&
                            (index == 0 ||
                                !sessionExerciseIds.contains(
                                  orderedExercises[index - 1].id,
                                ));
                        final showOtherHeader =
                            selectedSession != null &&
                            !isInSession &&
                            (index == 0 ||
                                sessionExerciseIds.contains(
                                  orderedExercises[index - 1].id,
                                ));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showSessionHeader)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'In this session',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (showOtherHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Other exercises',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            _ExerciseCard(
                              name: exercise.name,
                              highlighted:
                                  isInSession && selectedSession != null,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                context.push(
                                  '/gym/${widget.gymId}/exercises/${exercise.id}/log',
                                );
                              },
                              onLongPress: () {
                                HapticFeedback.lightImpact();
                                _confirmDeleteExercise(exercise);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddExerciseDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SessionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: onLongPress,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _EmptyExercisesView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyExercisesView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 48,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No exercises yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first exercise to start logging workouts',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final String name;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ExerciseCard({
    required this.name,
    required this.highlighted,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: widget.highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.55)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: Container(
            decoration: widget.highlighted
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary, width: 2),
                  )
                : null,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.highlighted
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.highlighted
                        ? Icons.star_rounded
                        : Icons.fitness_center_rounded,
                    color: widget.highlighted
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.highlighted
                          ? colorScheme.onPrimaryContainer
                          : null,
                    ),
                  ),
                ),
                if (widget.highlighted)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  const _AddExerciseDialog();

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<ExerciseBloc>().add(AddExerciseEvent(exerciseName: name));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fitness_center,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add exercise',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Name the movement you want to track',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Bench Press',
                prefixIcon: const Icon(Icons.sports_gymnastics_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _hasText ? _submit : null,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageSessionDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final ExerciseSession? existingSession;

  const _ManageSessionDialog({required this.exercises, this.existingSession});

  @override
  State<_ManageSessionDialog> createState() => _ManageSessionDialogState();
}

class _ManageSessionDialogState extends State<_ManageSessionDialog> {
  late final TextEditingController _nameController;
  late Set<String> _selectedExerciseIds;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingSession?.name ?? '',
    );
    _selectedExerciseIds = widget.existingSession?.exerciseIds.toSet() ?? {};
    _canSubmit =
        _nameController.text.trim().isNotEmpty &&
        _selectedExerciseIds.isNotEmpty;
    _nameController.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    final canSubmit =
        _nameController.text.trim().isNotEmpty &&
        _selectedExerciseIds.isNotEmpty;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateCanSubmit);
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedExerciseIds.isEmpty) return;

    if (widget.existingSession != null) {
      context.read<SessionBloc>().add(
        UpdateSessionEvent(
          session: ExerciseSession(
            id: widget.existingSession!.id,
            name: name,
            exerciseIds: _selectedExerciseIds.toList(),
          ),
        ),
      );
    } else {
      context.read<SessionBloc>().add(
        AddSessionEvent(
          sessionName: name,
          exerciseIds: _selectedExerciseIds.toList(),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.existingSession != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit session' : 'Create session',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Group exercises like Chest + Triceps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Chest + Triceps',
                  prefixIcon: const Icon(Icons.view_agenda_outlined),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select exercises',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = widget.exercises[index];
                    final selected = _selectedExerciseIds.contains(exercise.id);
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(exercise.name),
                      value: selected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedExerciseIds.add(exercise.id);
                          } else {
                            _selectedExerciseIds.remove(exercise.id);
                          }
                          _updateCanSubmit();
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    child: Text(isEditing ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
