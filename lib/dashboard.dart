import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bar.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key, required Map<String, int> frequentlyBoughtItems}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, int> frequentlyBoughtItems = {};
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadFrequentlyBoughtItems();
  }

  Future<void> _loadFrequentlyBoughtItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('frequentlyBoughtItems');

    if (storedData != null) {
      final Map<String, int> loadedData = Map<String, int>.from(jsonDecode(storedData));
      setState(() {
        frequentlyBoughtItems = loadedData;
      });
    } else {
      setState(() {
        frequentlyBoughtItems = {};
      });
    }
  }

  void _updateItemQuantity(String itemName, int newQuantity) async {
    setState(() {
      frequentlyBoughtItems[itemName] = newQuantity;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('frequentlyBoughtItems', jsonEncode(frequentlyBoughtItems));
  }

  @override
  Widget build(BuildContext context) {
    int totalFrequency = frequentlyBoughtItems.values.fold(0, (sum, value) => sum + value);
    if (frequentlyBoughtItems.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFB1E8DE),
        body: Center(
          child: Container(
            width: 330,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  'Frequently Bought Items',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No data available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    List<MapEntry<String, int>> sortedItems = frequentlyBoughtItems.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, int>> topItems = sortedItems.take(6).toList();

    Map<String, double> dataMap = {};
    for (var entry in topItems) {
      dataMap[entry.key] = entry.value.toDouble();
    }

    List<PieChartSectionData> sections = dataMap.entries.map((entry) {
      double percentage = (entry.value / totalFrequency) * 100;

      final isTouched = dataMap.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: Colors.accents[dataMap.keys.toList().indexOf(entry.key) % Colors.accents.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
      );
    }).toList();

    List<Widget> legendItems = dataMap.entries.map((entry) {
      String itemName = entry.key.split(' ').take(3).join(' ') + '...';

      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.accents[dataMap.keys.toList().indexOf(entry.key) % Colors.accents.length],
              ),
            ),
            SizedBox(width: 5),
            Text(
              itemName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:EdgeInsets.only(top: 25),
            child: Container(
              width: 330,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Frequently Bought',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                        sections: sections,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Wrap(
                      children: legendItems,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
