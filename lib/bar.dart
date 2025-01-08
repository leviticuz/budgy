import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class barChart extends StatefulWidget {
  final List<Map<String, double>> monthlyData;

  const barChart({super.key, required this.monthlyData});

  @override
  State<StatefulWidget> createState() => barChartState();
}

class barChartState extends State<barChart> {
  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = List.generate(12, (index) {
      double spending = widget.monthlyData[index]['spending'] ?? 0.0;
      double budget = widget.monthlyData[index]['budget'] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: spending, color: Colors.teal.shade300, width: 16),
          BarChartRodData(toY: budget, color: Colors.teal.shade800, width: 16),
        ],
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.bar_chart, color: Colors.white),
                SizedBox(width: 8),
                Text('Budget', style: TextStyle(color: Color(0xFF4DB6ACFF), fontSize: 18)),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 5 * 16.0,
                  child: BarChart(
                    BarChartData(
                      maxY: 150,
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitles),
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.teal.shade300,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Spending',
                        style: TextStyle(color: Color(0xFF4DB6AC), fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.teal.shade800,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Budget',
                        style: TextStyle(color: Color(0xFF00695C), fontSize: 16),
                      ),
                    ],
                  ),
                ],
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
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}