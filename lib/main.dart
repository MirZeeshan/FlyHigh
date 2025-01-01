import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/progress_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      routes: {
        '/workout': (context) => const WorkoutPage(),
        '/progress': (context) => const ProgressScreen(), 
      },
    );
  }
}