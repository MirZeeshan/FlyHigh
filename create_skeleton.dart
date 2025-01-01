// Dart script to create a Flutter project skeleton
import 'dart:io';

void main() async {
  print('Creating Flutter project skeleton...');

  // Directory structure
  final directories = [
    'lib/screens',
    'lib/widgets',
    'lib/database',
    'lib/utils',
    'ios',
    'macos',
    'ios/config',
    'macos/config',
    'test',
  ];

  // Files to create
  final files = {
    'lib/main.dart': _mainDartContent,
    'lib/screens/home_screen.dart': _homeScreenContent,
    'lib/screens/log_screen.dart': _logScreenContent,
    'lib/screens/progress_screen.dart': _progressScreenContent,
    'lib/database/db_helper.dart': _dbHelperContent,
    'lib/database/models.dart': _modelsContent,
    'lib/widgets/placeholder_widget.dart': _placeholderWidgetContent,
    'lib/utils/constants.dart': _constantsContent,
    'ios/config/Info.plist': _iosInfoPlistContent,
    'macos/config/Info.plist': _macosInfoPlistContent,
    'pubspec.yaml': _pubspecYamlContent,
    'README.md': _readmeContent,
  };

  // Create directories
  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Created directory: $dir');
    }
  }

  // Create files
  files.forEach((path, content) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      print('Created file: $path');
    }
  });

  print('Flutter project skeleton created successfully!');
}

const String _mainDartContent = """
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
""";

const String _homeScreenContent = """
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text('Welcome to Workout Tracker')),
    );
  }
}
""";

const String _logScreenContent = """
import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Workout')),
      body: Center(child: Text('Log your workouts here')),
    );
  }
}
""";

const String _progressScreenContent = """
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress')), 
      body: Center(child: Text('Track your progress here')),
    );
  }
}
""";

const String _dbHelperContent = """
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'workout_tracker.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        sets INTEGER,
        reps INTEGER,
        weight REAL,
        date TEXT
      )
    ''');
  }
}
""";

const String _modelsContent = """
class Workout {
  final int? id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final String date;

  Workout({this.id, required this.name, required this.sets, required this.reps, required this.weight, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'date': date,
    };
  }

  static Workout fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
      date: map['date'],
    );
  }
}
""";

const String _placeholderWidgetContent = """
import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final String title;

  PlaceholderWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: TextStyle(fontSize: 24)),
    );
  }
}
""";

const String _constantsContent = """
const String appName = 'Workout Tracker';
const double padding = 16.0;
""";

const String _iosInfoPlistContent = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Workout Tracker</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.workouttracker</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
""";

const String _macosInfoPlistContent = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Workout Tracker</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.workouttracker.macos</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
""";

const String _pubspecYamlContent = """
name: workout_tracker

description: A Flutter app to track workouts.

environment:
  sdk: ">=2.19.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.0.0+4
  path_provider: ^2.0.11
  charts_flutter: ^0.12.0

dev_dependencies:
  flutter_test:
    sdk: flutter
""";

const String _readmeContent = """
# Workout Tracker

A Flutter app to track workouts. This project is in development.

## Features
- Log workouts
- View progress
- Analyze performance

## Getting Started
1. Clone the repository.
2. Run `flutter pub get`.
3. Use `flutter run` to launch the app.
""";
