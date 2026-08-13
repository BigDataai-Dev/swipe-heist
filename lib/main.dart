import 'package:flutter/material.dart';
import 'src/puzzle_screen.dart';

void main() => runApp(const SwipePuzzleApp());

class SwipePuzzleApp extends StatelessWidget {
  const SwipePuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF65D9B5),
      ),
      home: const PuzzleScreen(),
    );
  }
}
