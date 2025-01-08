import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BarChartScreen extends StatefulWidget {
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  List<BarChartGroupData> _barGroups = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<BarChartGroupData> barGroups = [];

    for (int month = 1; month <= 12; month++) {
      String monthKey = "month_$month"; // Key for the month
      String? jsonString = prefs.getString(monthKey);

      if (jsonString != null) {
        Map<String, dynamic> monthData = jsonDecode(jsonString);
        double budget = monthData['budget'] ?? 0.0;
        double spending = monthData['spending'] ?? 0.0;

        barGroups.add(
          BarChartGroupData(
            x: month - 1,
            barRods: [
              BarChartRodData(
                toY: spending,
                color: Colors.teal.shade300,
                width: 16,
              ),
              BarChartRodData(
                toY: budget,
                color: Colors.teal.shade800,
                width: 16,
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _barGroups = barGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monthly Budget and Spending')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 5 * 16.0,
                  child: BarChart(
                    BarChartData(
                      maxY: 150,  // Adjust as needed
                      barGroups: _barGroups,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: bottomTitles,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 25),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      barTouchData: BarTouchData(enabled: true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Text(
      titles[value.toInt()],
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
