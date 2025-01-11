import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class barChart extends StatefulWidget {
  final DateTime selectedDate;

  barChart({required this.selectedDate});

  @override
  _barChartState createState() => _barChartState();
}

class _barChartState extends State<barChart> {
  List<Map<String, double>> monthlyData = [];
  double maxYValue = 10.0;
  double totalBudget = 0.0;
  double totalSpending = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final year = widget.selectedDate.year;

    List<Map<String, double>> tempData = [];
    double maxSpendingOrBudget = 0.0;

    for (int i = 0; i < 12; i++) {
      final month = (i + 1).toString().padLeft(2, '0');
      final monthKey = "$year-$month";

      final budget = prefs.getDouble("${monthKey}_budget") ?? 0.0;
      final spending = prefs.getDouble("${monthKey}_spending") ?? 0.0;

      totalBudget = budget;
      totalSpending = spending;

      tempData.add({"totalBudget": budget, "totalSpending": spending});
      maxSpendingOrBudget = max(maxSpendingOrBudget, max(budget, spending));
    }

    setState(() {
      monthlyData = tempData;
      maxYValue = (maxSpendingOrBudget * 1.5).ceilToDouble();
      if (maxYValue < 10) maxYValue = 10;
    });
  }

  List<BarChartGroupData> _generateChartGroups() {
    return List.generate(monthlyData.length, (index) {
      final data = monthlyData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data["totalSpending"] ?? 0.0,
            width: 22,
            color: Color(0xFF73b6aa),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          BarChartRodData(
            toY: data["totalBudget"] ?? 0.0,
            width: 22,
            color: Color(0xff158f79),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      );
    });
  }

  void _showBottomSheet(BuildContext context, String monthName, double budget, double spending) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (context) {
        return Container(
          color: Color(0xFFc2ece4),
          width: 365,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "$monthName",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF317165),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Budget:",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0e7860)),
                  ),
                  Text(
                    "₱${budget.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0e7860)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Spent:",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0e7860)),
                  ),
                  Text(
                    "₱${spending.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0e7860)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Saved:",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0e7860)),
                  ),
                  Text(
                    "₱${(budget - spending).toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF004b39)),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(
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
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Budget',
                style: TextStyle(
                  color: Color(0xFF317165),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              Container(
                width: double.infinity,
                height: 250,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scrollable Bar Chart
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: monthlyData.length * 60.0,
                          child: BarChart(
                            BarChartData(
                              maxY: maxYValue,
                              alignment: BarChartAlignment.spaceBetween,
                              barGroups: _generateChartGroups(),
                              borderData: FlBorderData(
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                              ),
                              gridData: FlGridData(
                                drawHorizontalLine: false,
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        final monthNames = [
                                          "January", "February", "March", "April", "May", "June",
                                          "July", "August", "September", "October", "November", "December"
                                        ];
                                        if (value >= 0 && value < monthNames.length) {
                                          final monthName = monthNames[value.toInt()];
                                          final shortMonthName = monthName.substring(0, 3);
                                          final data = monthlyData[value.toInt()];
                                          return GestureDetector(
                                            onTap: () {
                                              _showBottomSheet(
                                                context,
                                                monthName,
                                                data["totalBudget"] ?? 0.0,
                                                data["totalSpending"] ?? 0.0,
                                              );
                                            },
                                            child: Text(
                                              shortMonthName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF317165),
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                           );
                                        }
                                        return const SizedBox();
                                      }

                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Fixed Numbers on the Right
                    Container(
                      width: 50, // Fixed width for the right-side numbers
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5, // Adjust based on maxYValue
                              (index) {
                            // Calculate value to display on the right
                            double value = maxYValue * (1 - (index / 4)); // Inverted scaling (from bottom to top)
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 20),
              // Legend with circular indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF73b6aa),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Expenses",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF317165),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff158f79),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Budget",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF317165),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
