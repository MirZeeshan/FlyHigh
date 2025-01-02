import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../database/models.dart';

/// A screen that allows users to log their workout details.
///
/// Provides a form interface for users to input:
/// - Exercise name
/// - Number of sets
/// - Number of reps
/// - Weight used
/// - Optional notes
/// Supports multiple users and persists data to a local database.
class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({Key? key}) : super(key: key);

  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  // Form controllers for user input
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  // State variables
  DateTime _selectedDate = DateTime.now();
  User? _selectedUser;
  List<User> _users = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Logs message with timestamp in debug mode
  void _log(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$level] $timestamp: WorkoutLogScreen: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _log('Initializing WorkoutLogScreen');
    _loadUsers();
  }

  /// Loads all users from the database.
  ///
  /// Populates the user selection dropdown and handles any errors
  /// that occur during the loading process.
  Future<void> _loadUsers() async {
    try {
      _log('Loading users from database');
      final usersData = await _dbHelper.fetchAllUsers();
      setState(() {
        _users = usersData.map((map) => User.fromMap(map)).toList();
      });
      _log('Successfully loaded ${_users.length} users');
    } catch (e, stackTrace) {
      _log('Error loading users: $e\n$stackTrace', level: 'ERROR');
      _showErrorSnackBar('Error loading users: ${e.toString()}');
    }
  }

  /// Shows an error message to the user using a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _log('Disposing WorkoutLogScreen');
    // Clean up controllers
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Validates and submits the workout form.
  ///
  /// Creates new workout and exercise entries in the database.
  /// Shows success/error messages to the user based on the operation result.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedUser != null) {
      try {
        _log('Submitting workout form for user: ${_selectedUser!.name}');

        // Create the workout entry
        final workout = Workout(
          userId: _selectedUser!.userId!,
          date: _selectedDate,
          notes: _notesController.text,
          typeId: 1, // TODO: Add workout type selection
        );

        final workoutId = await _dbHelper.insertWorkout(workout.toMap());
        _log('Created workout with ID: $workoutId');

        // Create the exercise
        final exercise = Exercise(
          name: _exerciseController.text,
        );
        final exerciseId = await _dbHelper.insertExercise(exercise.toMap());
        _log('Created exercise with ID: $exerciseId');

        // Create the workout-exercise relationship
        final workoutExercise = WorkoutExercise(
          workoutId: workoutId,
          exerciseId: exerciseId,
          sets: int.tryParse(_setsController.text),
          reps: int.tryParse(_repsController.text),
          weight: int.tryParse(_weightController.text),
        );
        await _dbHelper.addExerciseToWorkout(workoutExercise.toMap());
        _log('Successfully saved workout exercise details');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e, stackTrace) {
        _log('Error saving workout: $e\n$stackTrace', level: 'ERROR');
        _showErrorSnackBar('Error saving workout: ${e.toString()}');
      }
    } else {
      _log('Form validation failed', level: 'WARNING');
    }
  }

  /// Resets all form fields to their initial state
  void _resetForm() {
    _log('Resetting workout form');
    _formKey.currentState?.reset();
    _exerciseController.clear();
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _log('Building WorkoutLogScreen UI');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _log('Navigating back from workout form');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User selection dropdown
                DropdownButtonFormField<User>(
                  decoration: const InputDecoration(
                    labelText: 'Select User',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedUser,
                  items: _users.map((User user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (User? newValue) {
                    setState(() {
                      _selectedUser = newValue;
                      _log('Selected user: ${newValue?.name}');
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a user' : null,
                ),
                const SizedBox(height: 16),

                // Exercise name input
                TextFormField(
                  controller: _exerciseController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter an exercise name'
                      : null,
                ),
                const SizedBox(height: 16),

                // Sets, reps, and weight inputs
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Optional notes input
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Workout',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
