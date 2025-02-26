import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_library_provider.dart';
import '../database/models.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isAddingExercise = false;

  void _log(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$level] $timestamp: ExerciseLibraryScreen: $message');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _exerciseNameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseLibraryNotifierProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _isAddingExercise = true;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search exercises',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(exerciseLibraryNotifierProvider.notifier)
                        .searchExercises('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  ref
                      .read(exerciseLibraryNotifierProvider.notifier)
                      .searchExercises(value);
                } else if (value.isEmpty) {
                  ref
                      .read(exerciseLibraryNotifierProvider.notifier)
                      .searchExercises('');
                }
              },
            ),
          ),
          _buildCategoryFilter(),
          if (_isAddingExercise) _buildAddExerciseForm(),
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const Center(
                    child: Text(
                        'No exercises found. Add some exercises to get started!'),
                  );
                }

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _buildExerciseCard(exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Strength', 'Cardio', 'Flexibility', 'Balance'];
    final selectedCategory = ref.watch(categoryFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedCategory == null,
            onSelected: (selected) {
              if (selected) {
                ref.read(categoryFilterProvider.notifier).setCategory(null);
                ref
                    .read(exerciseLibraryNotifierProvider.notifier)
                    .searchExercises('');
              }
            },
          ),
          const SizedBox(width: 8),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    ref
                        .read(categoryFilterProvider.notifier)
                        .setCategory(category);
                    ref
                        .read(exerciseLibraryNotifierProvider.notifier)
                        .filterByCategory(category);
                  } else {
                    ref.read(categoryFilterProvider.notifier).setCategory(null);
                    ref
                        .read(exerciseLibraryNotifierProvider.notifier)
                        .searchExercises('');
                  }
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAddExerciseForm() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _exerciseNameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Strength, Cardio, Flexibility',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isAddingExercise = false;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addExercise,
                    child: const Text('Add Exercise'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    if (_formKey.currentState!.validate()) {
      try {
        final exercise = Exercise(
          name: _exerciseNameController.text.trim(),
          category: _categoryController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await ref
            .read(exerciseLibraryNotifierProvider.notifier)
            .addExercise(exercise);

        setState(() {
          _isAddingExercise = false;
          _exerciseNameController.clear();
          _categoryController.clear();
          _descriptionController.clear();
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise added successfully!')),
        );
      } catch (e) {
        _log('Error adding exercise: $e', level: 'ERROR');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding exercise: $e')),
        );
      }
    }
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text(exercise.category ?? 'Uncategorized'),
        trailing: exercise.description?.isNotEmpty ?? false
            ? IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(exercise.name),
                      content: Text(exercise.description ?? ''),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
        onTap: () {
          // For adding to a workout - to be implemented
          Navigator.pop(context, exercise);
        },
      ),
    );
  }
}
