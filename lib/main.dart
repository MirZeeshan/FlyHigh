import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart' as home;
import 'screens/log_screen.dart';
import 'screens/progress_screen.dart' as progress;
import 'database/db_helper.dart';

/// Custom logger function that includes timestamp and log level
void _log(String message, {String level = 'INFO'}) {
  if (kDebugMode) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$level] $timestamp: $message');
  }
}

/// Entry point for the Workout Tracker application.
void main() async {
  try {
    _log('Initializing Workout Tracker application');

    WidgetsFlutterBinding.ensureInitialized();
    _log('Flutter bindings initialized');

    await DatabaseHelper.instance.initializeTestData();
    _log('Database initialization completed');

    runApp(const MyApp());
    _log('Application started successfully');
  } catch (e, stackTrace) {
    _log('Failed to initialize application: $e\n$stackTrace', level: 'ERROR');
    rethrow;
  }
}

/// Root widget of the Workout Tracker application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _log('Building MyApp widget');

    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          _log('Navigating to HomePage');
          return const home.HomePage();
        },
        '/workout': (context) {
          _log('Navigating to WorkoutPage');
          return const WorkoutPage();
        },
        '/progress': (context) {
          _log('Navigating to ProgressScreen');
          return const progress.ProgressScreen();
        },
      },
      onUnknownRoute: (settings) {
        _log('Unknown route requested: ${settings.name}', level: 'WARNING');
        return MaterialPageRoute(
          builder: (context) => const home.HomePage(),
        );
      },
    );
  }
}
