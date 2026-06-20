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
  final TextEditingController _repsController = TextEditingController();
  bool _updateEveryGym = false;

  @override
  void initState() {
    super.initState();
    context.read<LogBloc>().add(
      GetLogsEvent(gymId: widget.gymId, exerciseId: widget.exerciseId),
    );
  }

  void _submitLog() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final sets = int.tryParse(_setsController.text) ?? 1;
    final reps = int.tryParse(_repsController.text) ?? 1;

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
      _repsController.clear();
      setState(() => _updateEveryGym = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
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
            Expanded(
              child: BlocBuilder<LogBloc, LogState>(
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
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) {
                        final log = state.logs[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              '\${log.weight} kg (${log.sets} x ${log.reps})',
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
            ),
          ],
        ),
      ),
    );
  }
}
