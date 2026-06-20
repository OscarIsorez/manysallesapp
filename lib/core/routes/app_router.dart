import 'package:go_router/go_router.dart';
import '../../features/gym_tracking/presentation/pages/exercise_selection_page.dart';
import '../../features/gym_tracking/presentation/pages/gym_selection_page.dart';
import '../../features/gym_tracking/presentation/pages/log_weight_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const GymSelectionPage()),
    GoRoute(
      path: '/gym/:gymId/exercises',
      builder: (context, state) {
        final gymId = state.pathParameters['gymId']!;
        return ExerciseSelectionPage(gymId: gymId);
      },
    ),
    GoRoute(
      path: '/gym/:gymId/exercises/:exerciseId/log',
      builder: (context, state) {
        final gymId = state.pathParameters['gymId']!;
        final exerciseId = state.pathParameters['exerciseId']!;
        return LogWeightPage(gymId: gymId, exerciseId: exerciseId);
      },
    ),
  ],
);
