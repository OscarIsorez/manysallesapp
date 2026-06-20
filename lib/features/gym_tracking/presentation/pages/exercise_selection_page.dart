import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/exercise/exercise_bloc.dart';
import '../bloc/exercise/exercise_event.dart';
import '../bloc/exercise/exercise_state.dart';

class ExerciseSelectionPage extends StatelessWidget {
  final String gymId;
  const ExerciseSelectionPage({super.key, required this.gymId});

  void _showAddExerciseDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Exercise'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Exercise Name (e.g. Bench Press)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ExerciseBloc>().add(
                  AddExerciseEvent(exerciseName: controller.text),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Exercise')),
      body: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state is ExerciseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExerciseError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ExerciseLoaded) {
            if (state.exercises.isEmpty) {
              return const Center(child: Text('No exercises yet. Add one!'));
            }
            return ListView.builder(
              itemCount: state.exercises.length,
              itemBuilder: (context, index) {
                final exercise = state.exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  trailing: const Icon(Icons.fitness_center),
                  onTap: () {
                    context.push('/gym/$gymId/exercises/${exercise.id}/log');
                  },
                );
              },
            );
          }
          return const Center(child: Text('Initializing...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExerciseDialog(context),
        tooltip: 'Add Exercise',
        child: const Icon(Icons.add),
      ),
    );
  }
}
