import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final List<TextEditingController> _repsControllers = [
    TextEditingController(),
  ];
  bool _updateEveryGym = false;

  @override
  void initState() {
    super.initState();
    _setsController.addListener(_syncRepsFields);
    context.read<LogBloc>().add(
      GetLogsEvent(gymId: widget.gymId, exerciseId: widget.exerciseId),
    );
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
      _ensureRepControllers(targetSets);
    });
  }

  void _ensureRepControllers(int targetSets) {
    while (_repsControllers.length < targetSets) {
      _repsControllers.add(TextEditingController());
    }

    while (_repsControllers.length > targetSets) {
      _repsControllers.removeLast().dispose();
    }
  }

  void _submitLog() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final parsedSets = int.tryParse(_setsController.text) ?? 1;
    final sets = parsedSets < 1 ? 1 : parsedSets;
    _ensureRepControllers(sets);
    final reps = List<int>.generate(
      sets,
      (index) => int.tryParse(_repsControllers[index].text) ?? 1,
    );

    if (weight > 0) {
      context.read<LogBloc>().add(
        AddWeightLogEvent(
          gymId: widget.gymId,
          exerciseId: widget.exerciseId,
          weight: weight,
          sets: sets,
          reps: reps,
          updateEveryGym: _updateEveryGym,
        ),
      );

      _weightController.clear();
      _setsController.clear();
      for (final controller in _repsControllers) {
        controller.clear();
      }
      setState(() => _updateEveryGym = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sets'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reps per set',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_repsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _repsControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Set ${index + 1} reps',
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Modify this value for EVERY gym'),
                value: _updateEveryGym,
                onChanged: (val) =>
                    setState(() => _updateEveryGym = val ?? false),
              ),
              ElevatedButton(
                onPressed: _submitLog,
                child: const Text('Save Log'),
              ),
              const Divider(height: 32),
              const Text(
                'History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              BlocBuilder<LogBloc, LogState>(
                builder: (context, state) {
                  if (state is LogLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LogError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is LogsLoaded) {
                    if (state.logs.isEmpty) {
                      return const Center(child: Text('No history available.'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) {
                        final log = state.logs[index];
                        final repsText = log.reps.join(', ');
                        return Card(
                          child: ListTile(
                            title: Text(
                              '${log.weight} kg (${log.sets} sets: $repsText)',
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().add_jm().format(log.date),
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
