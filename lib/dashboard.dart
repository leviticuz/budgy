import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'productList.dart';

class Dashboard extends StatelessWidget {
  final Map<String, int> frequentlyBoughtItems;

  Dashboard({required this.frequentlyBoughtItems});

  @override
  Widget build(BuildContext context) {
    final data = frequentlyBoughtItems ?? {};

    if (data.isEmpty) {
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
    List<MapEntry<String, int>> sortedItems = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, int>> topItems = sortedItems.take(5).toList();

    Map<String, double> dataMap = {};
    for (var entry in topItems) {
      dataMap[entry.key] = entry.value.toDouble();
    }

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
                'Frequently Bought',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              PieChart(
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 3.5,
                legendOptions: LegendOptions(
                  legendPosition: LegendPosition.bottom,
                  showLegendsInRow: true,
                  legendShape: BoxShape.rectangle,
                  legendTextStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
