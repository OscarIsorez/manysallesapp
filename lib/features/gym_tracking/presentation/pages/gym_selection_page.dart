import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/gym/gym_bloc.dart';
import '../bloc/gym/gym_event.dart';
import '../bloc/gym/gym_state.dart';
import '../bloc/log/log_bloc.dart';
import '../bloc/log/log_event.dart';
import '../bloc/log/log_state.dart';

class GymSelectionPage extends StatelessWidget {
  const GymSelectionPage({super.key});

  void _showAddGymDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Gym'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Gym Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<GymBloc>().add(
                  AddGymEvent(gymName: controller.text),
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
      appBar: AppBar(
        title: const Text('Select a Gym'),
        actions: [
          BlocConsumer<LogBloc, LogState>(
            listener: (context, state) {
              if (state is DataExportedSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  context.read<LogBloc>().add(ExportDataEvent());
                },
                tooltip: 'Export JSON',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<GymBloc, GymState>(
        builder: (context, state) {
          if (state is GymLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GymError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is GymLoaded) {
            if (state.gyms.isEmpty) {
              return const Center(child: Text('No gyms yet. Add one!'));
            }
            return ListView.builder(
              itemCount: state.gyms.length,
              itemBuilder: (context, index) {
                final gym = state.gyms[index];
                return ListTile(
                  title: Text(gym.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/gym/${gym.id}/exercises');
                  },
                );
              },
            );
          }
          return const Center(child: Text('Initialize to start'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGymDialog(context),
        tooltip: 'Add Gym',
        child: const Icon(Icons.add),
      ),
    );
  }
}
