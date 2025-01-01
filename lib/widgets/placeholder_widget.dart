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
