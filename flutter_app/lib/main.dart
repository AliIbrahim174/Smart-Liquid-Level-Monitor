import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LiquidMonitorApp());
}

class LiquidMonitorApp extends StatelessWidget {
  const LiquidMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liquid Monitor',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
