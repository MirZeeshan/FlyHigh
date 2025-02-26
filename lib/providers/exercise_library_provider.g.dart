// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exerciseLibraryNotifierHash() =>
    r'fd89fb7d75cdf18f6f36a8dbdb2a7ce60d0b2c15';

/// Provider that manages the exercise library functionality
///
/// Copied from [ExerciseLibraryNotifier].
@ProviderFor(ExerciseLibraryNotifier)
final exerciseLibraryNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ExerciseLibraryNotifier, List<Exercise>>.internal(
  ExerciseLibraryNotifier.new,
  name: r'exerciseLibraryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exerciseLibraryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExerciseLibraryNotifier = AutoDisposeAsyncNotifier<List<Exercise>>;
String _$categoryFilterHash() => r'65aa1b12a7a5b30d3718ded1af1244a4b2aa30a7';

/// Provider for tracking the currently selected categories
///
/// Copied from [CategoryFilter].
@ProviderFor(CategoryFilter)
final categoryFilterProvider =
    AutoDisposeNotifierProvider<CategoryFilter, String?>.internal(
  CategoryFilter.new,
  name: r'categoryFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryFilter = AutoDisposeNotifier<String?>;
String _$searchQueryHash() => r'2c146927785523a0ddf51b23b777a9be4afdc092';

/// Provider for tracking search queries
///
/// Copied from [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
