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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
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

// The Following are CRUD Operations
// User Tables

//Create
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('Users', user);
  }

//Read
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final db = await database;
    return await db.query('Users');
  }

//Update
  Future<int> updateUser(int userId, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'Users',
      user,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

//Delete
  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'Users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllTypes() async {
    final db = await database;
    return await db.query('Types');
  }

//Workout Tables

//Create
  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('Workouts', workout);
  }

//Read all
  Future<List<Map<String, dynamic>>> fetchAllWorkouts() async {
    final db = await database;
    return await db.query('Workouts');
  }

//Read by type
  Future<List<Map<String, dynamic>>> fetchWorkoutsByType(int typeId) async {
    final db = await database;
    return await db.query(
      'Workouts',
      where: 'type_id = ?',
      whereArgs: [typeId],
    );
  }

//Update
  Future<int> updateWorkout(int workoutId, Map<String, dynamic> workout) async {
    final db = await database;
    return await db.update(
      'Workouts',
      workout,
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

//Delete
  Future<int> deleteWorkout(int workoutId) async {
    final db = await database;
    return await db.delete(
      'Workouts',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

//Exercise Tables

//Create
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('Exercises', exercise);
  }

//Read
  Future<List<Map<String, dynamic>>> fetchAllExercises() async {
    final db = await database;
    return await db.query('Exercises');
  }

//Update
  Future<int> updateExercise(int exerciseId, Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.update(
      'Exercises',
      exercise,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

//Delete
  Future<int> deleteExercise(int exerciseId) async {
    final db = await database;
    return await db.delete(
      'Exercises',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

//Workout_Exercises Tables

//Create
  Future<int> addExerciseToWorkout(Map<String, dynamic> workoutExercise) async {
    final db = await database;
    return await db.insert('Workout_Exercises', workoutExercise);
  }

//Read
  Future<List<Map<String, dynamic>>> fetchExercisesForWorkout(int workoutId) async {
    final db = await database;
    return await db.query(
      'Workout_Exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

//Delete
  Future<int> deleteWorkoutExercise(int workoutExerciseId) async {
    final db = await database;
    return await db.delete(
      'Workout_Exercises',
      where: 'workout_exercise_id = ?',
      whereArgs: [workoutExerciseId],
    );
  }

//Templates Table

//Create
  Future<int> insertTemplate(Map<String, dynamic> template) async {
    final db = await database;
    return await db.insert('Templates', template);
  }

//Read
  Future<List<Map<String, dynamic>>> fetchAllTemplates() async {
    final db = await database;
    return await db.query('Templates');
  }

//Update
  Future<int> updateTemplate(int templateId, Map<String, dynamic> template) async {
    final db = await database;
    return await db.update(
      'Templates',
      template,
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
  }

//Delete
  Future<int> deleteTemplate(int templateId) async {
    final db = await database;
    return await db.delete(
      'Templates',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
  }

//Template_Exercise Tables

//Create
  Future<int> addExerciseToTemplate(Map<String, dynamic> templateExercise) async {
    final db = await database;
    return await db.insert('Template_Exercises', templateExercise);
  }

//Read
  Future<List<Map<String, dynamic>>> fetchExercisesForTemplate(int templateId) async {
    final db = await database;
    return await db.query(
      'Template_Exercises',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
  }

//Delete
  Future<int> deleteTemplateExercise(int templateExerciseId) async {
    final db = await database;
    return await db.delete(
      'Template_Exercises',
      where: 'template_exercise_id = ?',
      whereArgs: [templateExerciseId],
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
}