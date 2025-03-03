import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/medicine_data.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final List<String> timeSlots = ["Morning", "Afternoon", "Evening", "Night"];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 80,
            color: Colors.teal,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Medicine Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Time slot card
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: Text(
                timeSlots[currentIndex],
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Status buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => toggleStatus(true),
                    child: Text('TAKEN'),
                    style: ElevatedButton.styleFrom(
                      primary: isStatusTaken() ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => toggleStatus(false),
                    child: Text('NOT TAKEN'),
                    style: ElevatedButton.styleFrom(
                      primary: !isStatusTaken() ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: previousSlot,
                  child: Text('PREVIOUS'),
                ),
                TextButton(
                  onPressed: nextSlot,
                  child: Text('NEXT'),
                ),
              ],
            ),
          ),

          // Stats button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatsScreen()),
                  );
                },
                child: Text('VIEW STATISTICS'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleStatus(bool taken) {
    if (prefs == null) return;

    String today = DateTime.now().toIso8601String().split('T')[0];
    String data = prefs.getString(today) ?? '{}';
    Map<String, dynamic> dayData = json.decode(data);

    dayData[timeSlots[currentIndex]] = taken;
    prefs.setString(today, json.encode(dayData));

    setState(() {});
  }

  bool isStatusTaken() {
    if (prefs == null) return false;

    String today = DateTime.now().toIso8601String().split('T')[0];
    String data = prefs.getString(today) ?? '{}';
    Map<String, dynamic> dayData = json.decode(data);

    return dayData[timeSlots[currentIndex]] ?? false;
  }

  void nextSlot() {
    setState(() {
      currentIndex = (currentIndex + 1) % timeSlots.length;
    });
  }

  void previousSlot() {
    setState(() {
      currentIndex = (currentIndex - 1 + timeSlots.length) % timeSlots.length;
    });
  }
} 
