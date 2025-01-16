import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialReportGenerator {

  Map<String, dynamic> _calculateMonthlyData(
      List<dynamic> itemList, String year, String month) {
    final filteredItems = itemList.where((item) {
      if (item['date'] == null) return false;
      final date = DateTime.parse(item['date']);
      return date.year.toString() == year && _months[date.month - 1] == month;
    }).toList();

    double totalBudget = filteredItems.fold(0.0, (sum, item) => sum + (item['budget'] ?? 0.0));
    double totalExpenses = filteredItems.fold(
        0.0,
            (sum, item) => sum +
            (item['items'] != null
                ? (item['items'] as List<dynamic>)
                .where((subItem) => subItem['isChecked'] == true)
                .fold(0.0, (subSum, subItem) => subSum + ((subItem['price']*subItem['quantity']) ?? 0.0))
                : 0.0));
    double totalSaved = totalBudget - totalExpenses;
    List frequentItems = _calculateFrequentItems(filteredItems);

    return {
      "budget": totalBudget,
      "expenses": totalExpenses,
      "saved": totalSaved,
      "frequentItems": frequentItems,
    };
  }

  Map<String, dynamic> _calculateWeeklyData(
      List<dynamic> itemList, String year, String month, String week) {
    final filteredItems = itemList.where((item) {
      if (item['date'] == null) return false;
      final date = DateTime.parse(item['date']);
      if (date.year.toString() != year || _months[date.month - 1] != month) {
        return false;
      }

      int weekNumber = ((date.day - 1) / 7).floor() + 1;
      String weekLabel = "${weekNumber}th Week";
      if (weekNumber == 1) weekLabel = "1st Week";
      if (weekNumber == 2) weekLabel = "2nd Week";
      if (weekNumber == 3) weekLabel = "3rd Week";
      if (weekNumber == 4) weekLabel = "4th Week";
      if (weekNumber == 5) weekLabel = "5th Week";

      return weekLabel == week;
    }).toList();

    double totalBudget = filteredItems.fold(0.0, (sum, item) => sum + (item['budget'] ?? 0.0));
    double totalExpenses = filteredItems.fold(
        0.0,
            (sum, item) => sum +
            (item['items'] != null
                ? (item['items'] as List<dynamic>)
                .where((subItem) => subItem['isChecked'] == true)
                .fold(0.0, (subSum, subItem) => subSum + ((subItem['price']*subItem['quantity']) ?? 0.0))
                : 0.0));
    double totalSaved = totalBudget - totalExpenses;
    List frequentItems = _calculateFrequentItems(filteredItems);

    return {
      "budget": totalBudget,
      "expenses": totalExpenses,
      "saved": totalSaved,
      "frequentItems": frequentItems,
    };
  }


  Future<void> showFinancialReport(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');

    if (itemListJson == null) {
      _showAlertDialog(context, "No existing data!");
      return;
    }

    List<dynamic> itemList;
    try {
      itemList = jsonDecode(itemListJson) ?? [];
    } catch (e) {
      _showAlertDialog(context, "Error parsing financial data!");
      return;
    }

    if (itemList.isEmpty) {
      _showAlertDialog(context, "No financial data available!");
      return;
    }

    String selectedYear = "2025";
    String selectedMonth = "January";
    String selectedWeek = "1st Week";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final annualData = _calculateAnnualData(itemList, selectedYear);
            final monthlyData =
            _calculateMonthlyData(itemList, selectedYear, selectedMonth);
            final weeklyData = _calculateWeeklyData(
              itemList,
              selectedYear,
              selectedMonth,
              selectedWeek,
            );

            return AlertDialog(
              title: Text("Budgy Financial Report"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Dropdown
                    DropdownButton<String>(
                      value: selectedYear,
                      items: _extractYears(itemList)
                          .map((year) => DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                            selectedMonth = "January"; // Reset month on year change
                            selectedWeek = "1st Week"; // Reset week on year change
                          });
                        }
                      },
                    ),
                    Text("Annual Total Budget: \₱${annualData['budget']}"),
                    Text("Annual Total Expenses: \₱${annualData['expenses']}"),
                    Text("Annual Total Saved: \₱${annualData['saved']}"),
                    Text("Frequently Bought Items:"),
                    ...annualData['frequentItems']
                        .map<Widget>((item) => Text(
                        "- ${item['name']} (${item['percentage']}%)"))
                        .toList(),

                    Divider(),

                    // Month Dropdown
                    DropdownButton<String>(
                      value: selectedMonth,
                      items: _months
                          .map((month) => DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth = value;
                            selectedWeek = "1st Week"; // Reset week on month change
                          });
                        }
                      },
                    ),
                    Text("Monthly Budget: \₱${monthlyData['budget']}"),
                    Text("Monthly Expenses: \₱${monthlyData['expenses']}"),
                    Text("Monthly Saved: \₱${monthlyData['saved']}"),
                    Text("Frequently Bought Items:"),
                    ...monthlyData['frequentItems']
                        .map<Widget>((item) => Text(
                        "- ${item['name']} (${item['percentage']}%)"))
                        .toList(),

                    Divider(),

                    // Week Dropdown
                    DropdownButton<String>(
                      value: selectedWeek,
                      items: _weeks
                          .map((week) => DropdownMenuItem<String>(
                        value: week,
                        child: Text(week),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedWeek = value;
                          });
                        }
                      },
                    ),
                    Text("Weekly Budget: \₱${weeklyData['budget']}"),
                    Text("Weekly Expenses: \₱${weeklyData['expenses']}"),
                    Text("Weekly Saved: \₱${weeklyData['saved']}"),
                    Text("Frequently Bought Items:"),
                    ...weeklyData['frequentItems']
                        .map<Widget>((item) => Text(
                        "- ${item['name']} (${item['percentage']}%)"))
                        .toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _extractYears(List<dynamic> itemList) {
    return itemList
        .where((item) => item['date'] != null)
        .map((item) => DateTime.parse(item['date']).year.toString())
        .toSet()
        .toList()
      ..sort();
  }

  Map<String, dynamic> _calculateAnnualData(
      List<dynamic> itemList, String year) {
    final filteredItems = itemList
        .where((item) =>
    item['date'] != null &&
        DateTime.parse(item['date']).year.toString() == year)
        .toList();

    double totalBudget = filteredItems.fold(0.0, (sum, item) => sum + (item['budget'] ?? 0.0));
    double totalExpenses = filteredItems.fold(
        0.0,
            (sum, item) => sum +
            (item['items'] != null
                ? (item['items'] as List<dynamic>)
                .where((subItem) => subItem['isChecked'] == true)
                .fold(0.0, (subSum, subItem) => subSum + ((subItem['price']*subItem['quantity']) ?? 0.0))
                : 0.0));

    double totalSaved = totalBudget - totalExpenses;
    List frequentItems = _calculateFrequentItems(filteredItems);

    return {
      "budget": totalBudget,
      "expenses": totalExpenses,
      "saved": totalSaved,
      "frequentItems": frequentItems,
    };
  }

  List<dynamic> _calculateFrequentItems(List<dynamic> filteredItems) {
    final Map<String, int> itemCounts = {};

    for (var item in filteredItems) {
      if (item['items'] != null) {
        for (var subItem in item['items']) {
          if (subItem['isChecked'] == true) {
            itemCounts[subItem['name']] = (itemCounts[subItem['name']] ?? 0) + 1;
          }
        }
      }
    }

    final totalCheckedItems = itemCounts.values.fold(0, (sum, count) => sum + count);
    final sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedItems.take(5).map((entry) {
      final percentage = ((entry.value / totalCheckedItems) * 100).toStringAsFixed(2);
      return {"name": entry.key, "percentage": percentage};
    }).toList();
  }

  final List<String> _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  final List<String> _weeks = [
    "1st Week",
    "2nd Week",
    "3rd Week",
    "4th Week",
    "5th Week"
  ];

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Budgy Financial Report"),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
