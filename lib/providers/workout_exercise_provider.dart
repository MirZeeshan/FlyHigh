// lib/providers/workout_exercise_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/models.dart';
import '../database/db_helper.dart';

part 'workout_exercise_provider.g.dart';

@riverpod
class WorkoutExerciseNotifier extends _$WorkoutExerciseNotifier {
  @override
  Future<List<WorkoutExercise>> build() async {
    return [];
  }

  Future<List<WorkoutExercise>> getExercisesForWorkout(int workoutId) async {
    state = const AsyncValue.loading();
    try {
      final exercisesData =
          await DatabaseHelper.instance.fetchExercisesForWorkout(workoutId);
      final exercises =
          exercisesData.map((map) => WorkoutExercise.fromMap(map)).toList();
      state = AsyncValue.data(exercises);
      return exercises;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> addWorkoutWithExercise(
    Workout workout,
    Exercise exercise,
    WorkoutExercise workoutExercise,
  ) async {
    state = const AsyncValue.loading();
    try {
      final db = DatabaseHelper.instance;

      // Create workout
      final workoutId = await db.insertWorkout(workout.toMap());

      // Create exercise
      final exerciseId = await db.insertExercise(exercise.toMap());

      // Link them together
      final exerciseData = workoutExercise
          .copyWith(
            workoutId: workoutId,
            exerciseId: exerciseId,
          )
          .toMap();

      await db.addExerciseToWorkout(exerciseData);

      // Refresh state
      state = AsyncValue.data(await getExercisesForWorkout(workoutId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Progress tracking provider
@riverpod
class ProgressStats extends _$ProgressStats {
  @override
  Future<Map<String, dynamic>> build() async {
    return _calculateStats();
  }

  Future<Map<String, dynamic>> _calculateStats() async {
    try {
      final exercises = await DatabaseHelper.instance.fetchAllExercises();
      final workouts = await DatabaseHelper.instance.fetchAllWorkouts();

      return {
        'totalWorkouts': workouts.length,
        'totalExercises': exercises.length,
        // Add more stats as needed
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshStats() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _calculateStats());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
