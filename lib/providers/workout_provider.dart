import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/models.dart';
import '../database/db_helper.dart';

part 'workout_provider.g.dart';

@riverpod
class WorkoutNotifier extends _$WorkoutNotifier {
  @override
  Future<List<Workout>> build() async {
    return _fetchWorkouts();
  }

  Future<List<Workout>> _fetchWorkouts() async {
    final workoutsData = await DatabaseHelper.instance.fetchAllWorkouts();
    return workoutsData.map((map) => Workout.fromMap(map)).toList();
  }

  Future<List<Workout>> fetchWorkoutsForUser(int userId) async {
    state = const AsyncValue.loading();
    try {
      final allWorkouts = await _fetchWorkouts();
      final userWorkouts =
          allWorkouts.where((w) => w.userId == userId).toList();
      state = AsyncValue.data(userWorkouts);
      return userWorkouts;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> addWorkout(Workout workout) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseHelper.instance.insertWorkout(workout.toMap());
      state = AsyncValue.data(await _fetchWorkouts());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWorkoutWithExercises(
    Workout workout,
    List<WorkoutExercise> exercises,
  ) async {
    state = const AsyncValue.loading();
    try {
      final db = DatabaseHelper.instance;
      final workoutId = await db.insertWorkout(workout.toMap());

      for (final exercise in exercises) {
        final exerciseMap = exercise.toMap();
        exerciseMap['workout_id'] = workoutId;
        await db.addExerciseToWorkout(exerciseMap);
      }

      state = AsyncValue.data(await _fetchWorkouts());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<WorkoutExercise>> getExercisesForWorkout(int workoutId) async {
    try {
      final exercisesData =
          await DatabaseHelper.instance.fetchExercisesForWorkout(workoutId);
      return exercisesData.map((map) => WorkoutExercise.fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
