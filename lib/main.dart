import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'screens/main_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  runApp(MedicineTrackerApp());
}

class MedicineTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        accentColor: Colors.blue,
        brightness: Brightness.light,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    MainScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return _screens[_currentIndex];
  }

  void switchScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
} 
