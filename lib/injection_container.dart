import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/gym_tracking/data/datasources/gym_tracking_local_data_source.dart';
import '../features/gym_tracking/data/repositories/gym_tracking_repository_impl.dart';
import '../features/gym_tracking/domain/entities/gym.dart';
import '../features/gym_tracking/domain/entities/exercise.dart';
import '../features/gym_tracking/domain/entities/weight_log.dart';
import '../features/gym_tracking/domain/repositories/gym_tracking_repository.dart';

import '../features/gym_tracking/domain/usecases/gym_usecases.dart';
import '../features/gym_tracking/domain/usecases/exercise_usecases.dart';
import '../features/gym_tracking/domain/usecases/log_usecases.dart';
import '../features/gym_tracking/presentation/bloc/gym/gym_bloc.dart';
import '../features/gym_tracking/presentation/bloc/exercise/exercise_bloc.dart';
import '../features/gym_tracking/presentation/bloc/log/log_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => GymBloc(getGyms: sl(), addGym: sl()));
  sl.registerFactory(() => ExerciseBloc(getExercises: sl(), addExercise: sl()));
  sl.registerFactory(
    () => LogBloc(
      getLogs: sl(),
      addWeightLog: sl(),
      exportData: sl(),
      importData: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetGyms(sl()));
  sl.registerLazySingleton(() => AddGym(sl()));
  sl.registerLazySingleton(() => GetExercises(sl()));
  sl.registerLazySingleton(() => AddExercise(sl()));
  sl.registerLazySingleton(() => GetLogsForGymAndExercise(sl()));
  sl.registerLazySingleton(() => AddWeightLog(sl()));
  sl.registerLazySingleton(() => ExportData(sl()));
  sl.registerLazySingleton(() => ImportData(sl()));

  // Repositories
  await Hive.initFlutter();

  Hive.registerAdapter(GymAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WeightLogAdapter());

  final gymBox = await Hive.openBox<Gym>('gyms');
  final exerciseBox = await Hive.openBox<Exercise>('exercises');
  final logBox = await Hive.openBox<WeightLog>('logs');

  // Repositories
  sl.registerLazySingleton<GymTrackingRepository>(
    () => GymTrackingRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<GymTrackingLocalDataSource>(
    () => GymTrackingLocalDataSourceImpl(
      gymBox: gymBox,
      exerciseBox: exerciseBox,
      logBox: logBox,
    ),
  );
}
