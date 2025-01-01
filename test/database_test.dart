import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flyhigh/database/db_helper.dart'; 

void main() {
  //late DatabaseHelper dbHelper;

  //initialize FFI and databseFactory to use FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
    dbHelper = DatabaseHelper.instance;
  });

    test('Database initializes correctly', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
    });

    test('Insert and fetch a user', () async {
      // Insert a user
      final user = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'password_hash': 'hashed_password',
      };
      final userId = await dbHelper.insertUser(user);
      expect(userId, isNonZero);

      // Fetch the user
      final users = await dbHelper.fetchAllUsers();
      expect(users.isNotEmpty, true);
      expect(users.first['name'], 'John Doe');
      expect(users.first['email'], 'john.doe@example.com');
    });

    test('Insert and fetch a workout', () async {
      // Insert a type (required for workout foreign key)
      final type = {
        'type_name': 'Cardio',
        'description': 'Endurance exercises',
        'default_metrics': 'duration',
      };
      final db = await dbHelper.database;
      final typeId = await db.insert('Types', type);
      expect(typeId, isNonZero);

      // Insert a user (required for workout foreign key)
      final user = {
        'name': 'Jane Doe',
        'email': 'jane.doe@example.com',
        'password_hash': 'hashed_password',
      };
      final userId = await dbHelper.insertUser(user);
      expect(userId, isNonZero);

      // Insert a workout
      final workout = {
        'user_id': userId,
        'date': '2024-01-01',
        'duration': 60,
        'notes': 'Morning cardio session',
        'type_id': typeId,
      };
      final workoutId = await dbHelper.insertWorkout(workout);
      expect(workoutId, isNonZero);

      // Fetch workouts
      final workouts = await dbHelper.fetchAllWorkouts();
      expect(workouts.isNotEmpty, true);
      expect(workouts.first['notes'], 'Morning cardio session');
      expect(workouts.first['duration'], 60);
    });

    test('Insert and fetch an exercise', () async {
      // Insert an exercise
      final exercise = {
        'name': 'Push-up',
        'category': 'Strength',
        'description': 'A bodyweight exercise for chest and arms.',
        'body_part': 'Chest',
      };
      final exerciseId = await dbHelper.insertExercise(exercise);
      expect(exerciseId, isNonZero);

      // Fetch exercises
      final exercises = await dbHelper.fetchAllExercises();
      expect(exercises.isNotEmpty, true);
      expect(exercises.first['name'], 'Push-up');
      expect(exercises.first['body_part'], 'Chest');
    });
  });
}
