import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart' as home;
import 'screens/workout_log_screen.dart' as workoutlog;
import 'screens/progress_screen.dart' as progress;
import 'screens/exercise_library_screen.dart';
import 'auth/auth_screens/user_registration_screen.dart';
import 'auth/auth_screens/login_screen.dart';
import 'database/db_helper.dart';

/// Custom logger function that includes timestamp and log level
void _log(String message, {String level = 'INFO'}) {
  if (kDebugMode) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$level] $timestamp: $message');
  }
}

/// Entry point for the Workout Tracker application.
///
/// Initializes Flutter bindings, sets up the database
/// with test data, and starts the application.
void main() async {
  try {
    _log('Initializing Workout Tracker application');

    // Ensure Flutter bindings are initialized before accessing platform channels
    WidgetsFlutterBinding.ensureInitialized();
    _log('Flutter bindings initialized');

    // Initialize database with test data
    await DatabaseHelper.instance.initializeTestData();
    _log('Database initialization completed');

    // Start the application
    runApp(
      const ProviderScope(
        child: MyApp(),
        ),
    );
    _log('Application started successfully');
  } catch (e, stackTrace) {
    _log('Failed to initialize application: $e\n$stackTrace', level: 'ERROR');
    rethrow; // Rethrow to let Flutter handle fatal errors
  }
}

/// Root widget of the Workout Tracker application.
///
/// Configures the application theme and routing system. Uses Material 3 design
/// and provides a consistent blue color scheme throughout the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _log('Building MyApp widget');

    return MaterialApp(
      title: 'Workout Tracker',

      // Configure application theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Add additional theme configuration here if needed:
        // cardTheme: CardTheme(...),
        // appBarTheme: AppBarTheme(...),
        // etc.
      ),

      // Define application routes
      initialRoute: '/',
      routes: {
        '/': (context) {
          _log('Navigating to HomePage');
          return const home.HomePage();
        },
        '/workout': (context) {
          _log('Navigating to WorkoutLogScreen');
          return const workoutlog.WorkoutLogScreen();
        },
        '/progress': (context) {
          _log('Navigating to ProgressScreen');
          return const progress.ProgressScreen();
        },
        '/register': (context) {
          _log('Navigating to UserRegistrationScreen');
          return const UserRegistrationScreen();
        },
        '/login': (context) {
          _log('Navigating to LoginScreen');
          return const LoginScreen();
        },
        '/exercise-library': (context) {
          _log('Navigating to ExerciseLibraryScreen');
          return const ExerciseLibraryScreen();
        },
      },

      // Error handling for unknown routes
      onUnknownRoute: (settings) {
        _log('Unknown route requested: ${settings.name}', level: 'WARNING');
        return MaterialPageRoute(
          builder: (context) => const home.HomePage(),
        );
      },
    );
  }
}
