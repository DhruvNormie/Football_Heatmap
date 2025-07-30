import 'package:flutter/material.dart';
import 'package:football_contours/Heatmap.dart';


void main() => runApp(const FootballApp());

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FootballHeatmap(),
      theme: ThemeData.dark(),
    );
  }
}