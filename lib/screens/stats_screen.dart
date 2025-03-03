import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool showDetailedAnalysis = false;
  late SharedPreferences prefs;
  String statsText = "Loading stats...";
  String detailedText = "";

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    updateStats();
  }

  void updateStats() {
    if (prefs == null) return;

    int totalDoses = 0;
    int totalTaken = 0;
    int daysTracked = 0;

    for (String key in prefs.getKeys()) {
      if (key.contains('-')) { // Only process date keys
        daysTracked++;
        Map<String, dynamic> dayData = json.decode(prefs.getString(key) ?? '{}');
        totalDoses += 4;
        totalTaken += dayData.values.where((v) => v == true).length;
      }
    }

    setState(() {
      if (daysTracked == 0) {
        statsText = "No data recorded yet";
      } else {
        double adherence = (totalTaken / totalDoses) * 100;
        statsText = """Days Tracked: $daysTracked

Total Doses Taken: $totalTaken out of $totalDoses

Adherence Rate: ${adherence.toStringAsFixed(1)}%

Keep up the good work!""";
      }
    });
  }

  void showDetailedAnalysis() {
    if (prefs == null) return;

    List<String> perfectDays = [];
    Map<String, List<String>> incompleteDays = {};

    List<String> sortedKeys = prefs.getKeys().where((k) => k.contains('-')).toList()
      ..sort((a, b) => b.compareTo(a));

    for (String key in sortedKeys) {
      Map<String, dynamic> dayData = json.decode(prefs.getString(key) ?? '{}');
      List<String> missedDoses = [];

      for (String slot in ["Morning", "Afternoon", "Evening", "Night"]) {
        if (dayData[slot] != true) {
          missedDoses.add(slot);
        }
      }

      String displayDate = DateFormat('MMMM dd, yyyy')
          .format(DateTime.parse(key));

      if (missedDoses.isEmpty) {
        perfectDays.add(displayDate);
      } else {
        incompleteDays[displayDate] = missedDoses;
      }
    }

    setState(() {
      detailedText = "Detailed Medicine Analysis:\n\n";

      if (perfectDays.isNotEmpty) {
        detailedText += "Perfect Days (All 4 doses taken):\n";
        for (String day in perfectDays.take(5)) {
          detailedText += "✓ $day\n";
        }
        if (perfectDays.length > 5) {
          detailedText += "...and ${perfectDays.length - 5} more days\n";
        }
      }

      if (incompleteDays.isNotEmpty) {
        detailedText += "\nDays with Missed Doses:\n";
        int count = 0;
        incompleteDays.forEach((day, missed) {
          if (count < 5) {
            detailedText += "⚠ $day: Missed ${missed.join(', ')}\n";
          }
          count++;
        });
        if (incompleteDays.length > 5) {
          detailedText += "...and ${incompleteDays.length - 5} more days\n";
        }
      }

      showDetailedAnalysis = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 16),
                Text(
                  statsText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: showDetailedAnalysis,
                  child: Text('SHOW DETAILED ANALYSIS'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal,
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('BACK TO TRACKER'),
                ),
                if (showDetailedAnalysis) ...[
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Text(
                        detailedText,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
