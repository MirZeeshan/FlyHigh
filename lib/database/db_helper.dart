import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHelper {
  static const String _databaseName = "workout_tracker.db";
  static const int _databaseVersion = 1;

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  // Database reference
  static Database? _database;

  // Add this getter implementation that was missing
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseSchema.usersTable);
    await db.execute(DatabaseSchema.typesTable);
    await db.execute(DatabaseSchema.workoutsTable);
    await db.execute(DatabaseSchema.exercisesTable);
    await db.execute(DatabaseSchema.workoutExercisesTable);
    await db.execute(DatabaseSchema.templatesTable);
    await db.execute(DatabaseSchema.templateExercisesTable);
  }

  // Initialize test data
  Future<void> initializeTestData() async {
    final db = await database;
    final types = await db.query('Types');
    if (types.isEmpty) {
      await db.insert('Types', {
        'type_name': 'Strength Training',
        'description': 'Weight lifting and resistance training',
        'default_metrics': 'sets,reps,weight'
      });

      await db.insert('Types', {
        'type_name': 'Cardio',
        'description': 'Cardiovascular exercises',
        'default_metrics': 'duration,distance,heart_rate'
      });
    }
  }

  // User CRUD Operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('Users', user);
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final db = await database;
    return await db.query('Users');
  }

  Future<int> updateUser(int userId, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'Users',
      user,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'Users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Workout CRUD Operations
  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('Workouts', workout);
  }

  Future<List<Map<String, dynamic>>> fetchAllWorkouts() async {
    final db = await database;
    return await db.query('Workouts');
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutsByType(int typeId) async {
    final db = await database;
    return await db.query(
      'Workouts',
      where: 'type_id = ?',
      whereArgs: [typeId],
    );
  }

  // Exercise Operations
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('Exercises', exercise);
  }

  Future<int> addExerciseToWorkout(Map<String, dynamic> workoutExercise) async {
    final db = await database;
    return await db.insert('Workout_Exercises', workoutExercise);
  }

  Future<List<Map<String, dynamic>>> fetchExercisesForWorkout(
      int workoutId) async {
    final db = await database;
    return await db.query(
      'Workout_Exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }
}

class DatabaseSchema {
  static const String usersTable = '''
  CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
  ''';

  static const String typesTable = '''
  CREATE TABLE Types (
    type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type_name TEXT UNIQUE NOT NULL,
    description TEXT,
    default_metrics TEXT
  );
  ''';

  static const String workoutsTable = '''
  CREATE TABLE Workouts (
    workout_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    date DATE NOT NULL,
    duration INTEGER,
    notes TEXT,
    calories_burned INTEGER,
    type_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (type_id) REFERENCES Types (type_id)
  );
  ''';

  static const String exercisesTable = '''
  CREATE TABLE Exercises (
    exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT,
    description TEXT,
    body_part TEXT
  );
  ''';

  static const String workoutExercisesTable = '''
  CREATE TABLE Workout_Exercises (
    workout_exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    sets INTEGER,
    reps INTEGER,
    weight INTEGER,
    duration INTEGER,
    FOREIGN KEY (workout_id) REFERENCES Workouts (workout_id),
    FOREIGN KEY (exercise_id) REFERENCES Exercises (exercise_id)
  );
  ''';

  static const String templatesTable = '''
  CREATE TABLE Templates (
    template_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    type_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users (user_id),
    FOREIGN KEY (type_id) REFERENCES Types (type_id)
  );
  ''';

  static const String templateExercisesTable = '''
  CREATE TABLE Template_Exercises (
    template_exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,
    sets INTEGER,
    reps INTEGER,
    weight INTEGER,
    duration INTEGER,
    FOREIGN KEY (template_id) REFERENCES Templates (template_id),
    FOREIGN KEY (exercise_id) REFERENCES Exercises (exercise_id)
  );
  ''';
  static const String bodyweightTable = '''
  CREATE TABLE bodyweights (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  weight REAL NOT NULL,
  date TEXT NOT NULL
);
''';
}