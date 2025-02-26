// lib/providers/exercise_library_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/models.dart';
import '../database/db_helper.dart';

part 'exercise_library_provider.g.dart';

/// Provider that manages the exercise library functionality
@riverpod
class ExerciseLibraryNotifier extends _$ExerciseLibraryNotifier {
  @override
  Future<List<Exercise>> build() async {
    return _fetchExercises();
  }

  /// Fetches all exercises from the database
  Future<List<Exercise>> _fetchExercises() async {
    final exercisesData = await DatabaseHelper.instance.fetchAllExercises();
    return exercisesData.map((map) => Exercise.fromMap(map)).toList();
  }

  /// Adds a new exercise to the library
  Future<void> addExercise(Exercise exercise) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseHelper.instance.insertExercise(exercise.toMap());
      state = AsyncValue.data(await _fetchExercises());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Searches exercises by name or category
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.isEmpty) {
      return _fetchExercises();
    }

    state = const AsyncValue.loading();
    try {
      final results = await DatabaseHelper.instance.searchExercises(query);
      final exercises = results.map((map) => Exercise.fromMap(map)).toList();
      state = AsyncValue.data(exercises);
      return exercises;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Filters exercises by category
  Future<List<Exercise>> filterByCategory(String category) async {
    state = const AsyncValue.loading();
    try {
      final results =
          await DatabaseHelper.instance.fetchExercisesByCategory(category);
      final exercises = results.map((map) => Exercise.fromMap(map)).toList();
      state = AsyncValue.data(exercises);
      return exercises;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider for tracking the currently selected categories
@riverpod
class CategoryFilter extends _$CategoryFilter {
  @override
  String? build() => null;

  void setCategory(String? category) {
    state = category;
  }
}

/// Provider for tracking search queries
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}
