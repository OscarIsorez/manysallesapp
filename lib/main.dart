import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'features/gym_tracking/presentation/bloc/gym/gym_bloc.dart';
import 'features/gym_tracking/presentation/bloc/gym/gym_event.dart';
import 'features/gym_tracking/presentation/bloc/exercise/exercise_bloc.dart';
import 'features/gym_tracking/presentation/bloc/exercise/exercise_event.dart';
import 'features/gym_tracking/presentation/bloc/log/log_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GymBloc>(
          create: (_) => di.sl<GymBloc>()..add(GetGymsEvent()),
        ),
        BlocProvider<ExerciseBloc>(
          create: (_) => di.sl<ExerciseBloc>()..add(GetExercisesEvent()),
        ),
        BlocProvider<LogBloc>(create: (_) => di.sl<LogBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Gym Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 211, 68)),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
