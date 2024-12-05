import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class Dashboard extends StatelessWidget {
  final Map<String, double> dataMap = {
    "Corned Beef": 5,
    "Instant Noodles": 3,
    "Coffee": 2,
    "Powdered Milk": 2,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      body: Center(
        child: Container(
            width: 500,
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
                Text(
                  'Frequently bought',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20), // Spacing between text and chart
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
