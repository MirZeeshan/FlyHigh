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
