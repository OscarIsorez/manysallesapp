import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weight_log.dart';
import '../../domain/entities/exercise.dart';
import '../bloc/exercise/exercise_bloc.dart';
import '../bloc/exercise/exercise_event.dart';
import '../bloc/exercise/exercise_state.dart';
import '../bloc/log/log_bloc.dart';
import '../bloc/log/log_event.dart';
import '../bloc/log/log_state.dart';

class LogWeightPage extends StatefulWidget {
  final String gymId;
  final String exerciseId;

  const LogWeightPage({
    super.key,
    required this.gymId,
    required this.exerciseId,
  });

  @override
  State<LogWeightPage> createState() => _LogWeightPageState();
}

class _LogWeightPageState extends State<LogWeightPage> {
  static const double _weightStep = 0.25;
  static const double _maxWeight = 300;
  static int _weightItemCount =
      ((_maxWeight - _weightStep) / _weightStep).round() + 1;
  static const int _minSets = 1;
  static const int _maxSets = 20;
  static const int _setItemCount = _maxSets - _minSets + 1;

  final List<TextEditingController> _repsControllers = [
    TextEditingController(),
  ];
  double _weight = 0.25;
  int _sets = 1;
  late final FixedExtentScrollController _weightPickerController;
  late final FixedExtentScrollController _setsPickerController;
  bool _updateEveryGym = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _weightPickerController = FixedExtentScrollController(initialItem: 0);
    _setsPickerController = FixedExtentScrollController(initialItem: 0);
    context.read<LogBloc>().add(
      GetLogsEvent(gymId: widget.gymId, exerciseId: widget.exerciseId),
    );
  }

  @override
  void dispose() {
    _weightPickerController.dispose();
    _setsPickerController.dispose();
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureRepControllers(int targetSets) {
    while (_repsControllers.length < targetSets) {
      _repsControllers.add(TextEditingController());
    }

    while (_repsControllers.length > targetSets) {
      _repsControllers.removeLast().dispose();
    }
  }

  void _changeRepValue(int index, int delta) {
    final currentValue = int.tryParse(_repsControllers[index].text) ?? 1;
    final updatedValue = (currentValue + delta).clamp(1, 999);
    setState(() {
      _repsControllers[index].text = updatedValue.toString();
    });
    HapticFeedback.selectionClick();
  }

  void _submitLog() {
    _ensureRepControllers(_sets);
    final reps = List<int>.generate(
      _sets,
      (index) => int.tryParse(_repsControllers[index].text) ?? 3,
    );

    if (_weight > 0) {
      context.read<LogBloc>().add(
        AddWeightLogEvent(
          gymId: widget.gymId,
          exerciseId: widget.exerciseId,
          weight: _weight,
          sets: _sets,
          reps: reps,
          updateEveryGym: _updateEveryGym,
        ),
      );

      setState(() {
        _weight = _weightStep;
        _sets = _minSets;
      });
      // _weightPickerController.jumpToItem(0);
      // _setsPickerController.jumpToItem(0);
      for (final controller in _repsControllers) {
        controller.clear();
      }
      setState(() => _updateEveryGym = false);
    }
  }

  void _prefillFromLog(WeightLog log) {
    final snappedWeight = (log.weight / _weightStep).round() * _weightStep;
    final clampedWeight = snappedWeight
        .clamp(_weightStep, _maxWeight)
        .toDouble();
    final pickerIndex = ((clampedWeight - _weightStep) / _weightStep).round();
    final clampedSets = log.sets.clamp(_minSets, _maxSets);
    final setPickerIndex = clampedSets - _minSets;

    _weight = clampedWeight;
    _sets = clampedSets;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _weightPickerController.jumpToItem(pickerIndex);
      _setsPickerController.jumpToItem(setPickerIndex);
    });

    _ensureRepControllers(clampedSets);

    for (int i = 0; i < log.reps.length; i++) {
      _repsControllers[i].text = log.reps[i].toString();
    }

    setState(() {});
  }

  Future<void> _confirmDeleteLog(WeightLog log) async {
    final repsText = log.reps.join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          title: const Text('Delete this log?'),
          content: Text(
            'Remove ${log.weight} kg (${log.sets} sets: $repsText) from '
            '${DateFormat.yMMMd().add_jm().format(log.date)}?\n\n'
            'This action cannot be undone.',
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
      context.read<LogBloc>().add(
        DeleteWeightLogEvent(
          logId: log.id,
          gymId: widget.gymId,
          exerciseId: widget.exerciseId,
        ),
      );
    }
  }

  void _showRenameExerciseDialog(Exercise? exercise) {
    if (exercise == null) return;
    final controller = TextEditingController(text: exercise.name);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rename Exercise',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rename exercise',
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Exercise Name',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty) {
                          context.read<ExerciseBloc>().add(
                            UpdateExerciseEvent(
                              exercise: Exercise(
                                id: exercise.id,
                                name: newName,
                              ),
                            ),
                          );
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _editLog(WeightLog log) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Log',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => _EditLogDialog(
        log: log,
        onSave: (updatedLog) {
          context.read<LogBloc>().add(
            UpdateWeightLogEvent(
              weightLog: updatedLog,
              gymId: widget.gymId,
              exerciseId: widget.exerciseId,
            ),
          );
        },
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final exerciseState = context.watch<ExerciseBloc>().state;
    String exerciseName = 'Log Workout';
    Exercise? currentExercise;
    if (exerciseState is ExerciseLoaded) {
      currentExercise = exerciseState.exercises.firstWhere(
        (e) => e.id == widget.exerciseId,
        orElse: () => Exercise(id: widget.exerciseId, name: 'Log Workout'),
      );
      exerciseName = currentExercise!.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename exercise',
            onPressed: () => _showRenameExerciseDialog(currentExercise),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weight (kg)',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 180,
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _weight.toStringAsFixed(2),
                                      textAlign: TextAlign.center,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: CupertinoPicker(
                                        scrollController:
                                            _weightPickerController,
                                        itemExtent: 32,
                                        useMagnifier: true,
                                        magnification: 1.08,
                                        selectionOverlay:
                                            const CupertinoPickerDefaultSelectionOverlay(),
                                        onSelectedItemChanged: (index) {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _weight =
                                                _weightStep +
                                                (index * _weightStep);
                                          });
                                        },
                                        children: List.generate(
                                          _weightItemCount,
                                          (index) {
                                            final value =
                                                _weightStep +
                                                (index * _weightStep);
                                            return Center(
                                              child: Text(
                                                value.toStringAsFixed(2),
                                                style: textTheme.bodyLarge,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sets',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 180,
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_sets',
                                      textAlign: TextAlign.center,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: CupertinoPicker(
                                        scrollController: _setsPickerController,
                                        itemExtent: 32,
                                        useMagnifier: true,
                                        magnification: 1.08,
                                        selectionOverlay:
                                            const CupertinoPickerDefaultSelectionOverlay(),
                                        onSelectedItemChanged: (index) {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _sets = _minSets + index;
                                            _ensureRepControllers(_sets);
                                          });
                                        },
                                        children: List.generate(_setItemCount, (
                                          index,
                                        ) {
                                          final value = _minSets + index;
                                          return Center(
                                            child: Text(
                                              '$value',
                                              style: textTheme.bodyLarge,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reps per set',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_repsControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _repsControllers[index],
                                readOnly: true,
                                showCursor: false,
                                enableInteractiveSelection: false,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'Set ${index + 1} reps',
                                  filled: true,
                                  fillColor:
                                      colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _changeRepValue(index, 1),
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Increase reps',
                                ),
                                const SizedBox(height: 6),
                                IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _changeRepValue(index, -1),
                                  icon: const Icon(Icons.remove),
                                  tooltip: 'Decrease reps',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Modify this value for EVERY gym'),
                      value: _updateEveryGym,
                      onChanged: (val) =>
                          setState(() => _updateEveryGym = val ?? false),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _submitLog,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Save Log'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.history_rounded, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'History',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BlocConsumer<LogBloc, LogState>(
                listener: (context, state) {
                  if (state is LogDeletedSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Text('Log entry deleted'),
                      ),
                    );
                  }

                  if (state is LogUpdatedSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Text('Log entry updated'),
                      ),
                    );
                  }

                  if (state is LogsLoaded && !_prefilled) {
                    _prefillFromLog(state.latestLog);
                    _prefilled = true;
                  }
                },
                builder: (context, state) {
                  if (state is LogLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is LogError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is LogsLoaded) {
                    if (state.logs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No history yet',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.logs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final log = state.logs[index];
                        final repsText = log.reps.join(', ');
                        return Material(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              '${log.weight} kg',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${log.sets} sets · $repsText\n'
                              '${DateFormat.yMMMd().add_jm().format(log.date)}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  tooltip: 'Edit log',
                                  onPressed: () => _editLog(log),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: colorScheme.error,
                                  ),
                                  tooltip: 'Delete log',
                                  onPressed: () => _confirmDeleteLog(log),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditLogDialog extends StatefulWidget {
  final WeightLog log;
  final ValueChanged<WeightLog> onSave;

  const _EditLogDialog({required this.log, required this.onSave});

  @override
  State<_EditLogDialog> createState() => _EditLogDialogState();
}

class _EditLogDialogState extends State<_EditLogDialog> {
  late final TextEditingController _weightController;
  late final TextEditingController _setsController;
  late final List<TextEditingController> _repsControllers;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.log.weight.toString(),
    );
    _setsController = TextEditingController(text: widget.log.sets.toString());
    _repsControllers = List.generate(widget.log.sets, (index) {
      final repValue = index < widget.log.reps.length
          ? widget.log.reps[index]
          : 1;
      return TextEditingController(text: repValue.toString());
    });
    _setsController.addListener(_syncRepsFields);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _setsController.removeListener(_syncRepsFields);
    _setsController.dispose();
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncRepsFields() {
    final targetSets = int.tryParse(_setsController.text);
    if (targetSets == null ||
        targetSets < 1 ||
        targetSets == _repsControllers.length) {
      return;
    }

    setState(() {
      while (_repsControllers.length < targetSets) {
        final nextIndex = _repsControllers.length;
        final repValue = nextIndex < widget.log.reps.length
            ? widget.log.reps[nextIndex]
            : 1;
        _repsControllers.add(TextEditingController(text: repValue.toString()));
      }
      while (_repsControllers.length > targetSets) {
        _repsControllers.removeLast().dispose();
      }
    });
  }

  void _changeRepValue(int index, int delta) {
    final currentValue = int.tryParse(_repsControllers[index].text) ?? 1;
    final updatedValue = (currentValue + delta).clamp(1, 999);
    setState(() {
      _repsControllers[index].text = updatedValue.toString();
    });
    HapticFeedback.selectionClick();
  }

  void _submit() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final parsedSets = int.tryParse(_setsController.text) ?? 1;
    final sets = parsedSets < 1 ? 1 : parsedSets;

    // Ensure controllers list matches the final sets count
    while (_repsControllers.length < sets) {
      _repsControllers.add(TextEditingController());
    }
    while (_repsControllers.length > sets) {
      _repsControllers.removeLast().dispose();
    }

    final reps = List<int>.generate(
      sets,
      (index) => int.tryParse(_repsControllers[index].text) ?? 1,
    );

    if (weight > 0) {
      final updatedLog = WeightLog(
        id: widget.log.id,
        gymId: widget.log.gymId,
        exerciseId: widget.log.exerciseId,
        weight: weight,
        sets: sets,
        reps: reps,
        date: widget.log.date, // keep original date
      );
      widget.onSave(updatedLog);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit log entry',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sets',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reps per set',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_repsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _repsControllers[index],
                          readOnly: true,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Set ${index + 1} reps',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _changeRepValue(index, 1),
                            icon: const Icon(Icons.add),
                            tooltip: 'Increase reps',
                          ),
                          const SizedBox(height: 6),
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _changeRepValue(index, -1),
                            icon: const Icon(Icons.remove),
                            tooltip: 'Decrease reps',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
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
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save'),
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
