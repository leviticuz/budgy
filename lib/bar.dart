import 'package:Budgy/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';


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
    totalBudget = 0;
    totalSpending = 0;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final year = widget.selectedDate.year;
    print("Selected Year: $year");

    List<Map<String, double>> tempData = List.generate(12, (_) => {"totalBudget": 0.0, "totalSpending": 0.0});
    double maxSpendingOrBudget = 0.0;

    // Retrieve the saved item list
    final itemListJson = prefs.getString('itemList');
    if (itemListJson != null) {
      List<dynamic> itemList = jsonDecode(itemListJson);

      for (var item in itemList) {
        DateTime itemDate = DateTime.parse(item["date"]);
        if (itemDate.year == year) {
          int monthIndex = itemDate.month - 1; // Convert to 0-based index

          // Extract budget
          double budget = (item["budget"] ?? 0.0);

          // Calculate total spending from items
          double totalSpending = 0.0;
          List<dynamic> items = item["items"] ?? [];
          for (var itemDetail in items) {
            totalSpending += (itemDetail["price"] ?? 0.0);
          }

          // Accumulate per month
          tempData[monthIndex]["totalBudget"] = (tempData[monthIndex]["totalBudget"] ?? 0.0) + budget;
          tempData[monthIndex]["totalSpending"] = (tempData[monthIndex]["totalSpending"] ?? 0.0) + totalSpending;

          // Track the highest value for scaling the chart
          maxSpendingOrBudget = max(maxSpendingOrBudget, max(tempData[monthIndex]["totalBudget"]!, tempData[monthIndex]["totalSpending"]!));
        }
      }
    }

    setState(() {
      monthlyData = tempData;
      maxYValue = (maxSpendingOrBudget * 1.5).ceilToDouble();
      if (maxYValue < 10) maxYValue = 10;
    });

    print("Monthly Data: $monthlyData"); // Debug output
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
    final isOverspent = spending > budget;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFc2ece4), // Background color
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)), // Rounded corners
          ),
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
                    "Budget",
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
                    "Spent",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0e7860)),
                  ),
                  Text(
                    "₱${spending.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 16,color: Color(0xFF0e7860)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Saved",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFF0e7860)),
                  ),
                  Text(
                    "₱${(budget - spending).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOverspent ? Color(0xFFa60f15) : Color(0xFF004b39),
                    ),
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
                                drawHorizontalLine: true,
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
                                          final budget = data["totalBudget"] ?? 0.0;
                                          final spending = data["totalSpending"] ?? 0.0;

                                          if (budget > 0 || spending > 0) {
                                            return GestureDetector(
                                              onTap: () {
                                                _showBottomSheet(
                                                  context,
                                                  monthName,
                                                  budget,
                                                  spending,
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
                                          } else {
                                            return Text(
                                              shortMonthName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                decoration: TextDecoration.none,
                                              ),
                                            );
                                          }
                                        }
                                        return SizedBox();
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
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                              (index) {
                            double value = maxYValue * (1 - (index / 4));
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