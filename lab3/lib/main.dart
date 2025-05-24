import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/add_workout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/add': (context) => const AddWorkoutPage(),
      },
    );
  }
}
