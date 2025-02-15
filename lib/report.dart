import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

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

  Map<String, dynamic> _calculateDailyData(
      List<dynamic> itemList, String year, String month, String day) {
    final filteredItems = itemList.where((item) {
      if (item['date'] == null) return false;
      final date = DateTime.parse(item['date']);
      return date.year.toString() == year &&
          _months[date.month - 1] == month &&
          date.day.toString() == day;
    }).toList();

    double totalBudget =
    filteredItems.fold(0.0, (sum, item) => sum + (item['budget'] ?? 0.0));
    double totalExpenses = filteredItems.fold(
        0.0,
            (sum, item) =>
        sum +
            (item['items'] != null
                ? (item['items'] as List<dynamic>)
                .where((subItem) => subItem['isChecked'] == true)
                .fold(
                0.0,
                    (subSum, subItem) =>
                subSum + ((subItem['price'] * subItem['quantity']) ?? 0.0))
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

    // Fetch and decode itemList
    final itemListJson = prefs.getString('itemList');
    List<dynamic> itemList = [];
    if (itemListJson != null) {
      try {
        itemList = jsonDecode(itemListJson);
      } catch (e) {
        _showAlertDialog(context, "Error parsing itemList data!");
        return;
      }
    }

    // Fetch and decode archivedItems
    final archiveListRaw = prefs.getStringList('archivedItems');
    List<dynamic> archiveList = [];
    if (archiveListRaw != null) {
      try {
        archiveList = archiveListRaw.map((e) => jsonDecode(e)).toList();
      } catch (e) {
        _showAlertDialog(context, "Error parsing archivedItems data!");
        return;
      }
    }

    // Combine both lists
    List<dynamic> combinedList = [...itemList, ...archiveList];

    if (combinedList.isEmpty) {
      _showAlertDialog(context, "No financial data available!");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialReportScreen(itemList: combinedList),
      ),
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

class FinancialReportScreen extends StatefulWidget {
  final List<dynamic> itemList;

  const FinancialReportScreen({Key? key, required this.itemList}) : super(key: key);

  @override
  _FinancialReportScreenState createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  String selectedYear = "2025";
  String selectedMonth = "January";
  String selectedWeek = "1st Week";
  String selectedDay = "1";

  late Map<String, dynamic> annualData;
  late Map<String, dynamic> monthlyData;
  late Map<String, dynamic> weeklyData;
  late Map<String, dynamic> dailyData;

  @override
  void initState() {
    super.initState();
    _calculateReports();
  }

  void _calculateReports() {
    final generator = FinancialReportGenerator();
    annualData = generator._calculateAnnualData(widget.itemList, selectedYear);
    monthlyData = generator._calculateMonthlyData(widget.itemList, selectedYear, selectedMonth);
    weeklyData = generator._calculateWeeklyData(widget.itemList, selectedYear, selectedMonth, selectedWeek);
    dailyData = generator._calculateDailyData(widget.itemList, selectedYear, selectedMonth, selectedDay);
  }

  List<String> _getDaysInMonth() {
    int monthIndex = FinancialReportGenerator()._months.indexOf(selectedMonth) + 1;
    int year = int.parse(selectedYear);
    int daysInMonth = DateTime(year, monthIndex + 1, 0).day;
    return List.generate(daysInMonth, (index) => (index + 1).toString());
  }

  Widget _buildPieChart(double budget, double expenses, double saved) {

    double expenseValue = (expenses/budget)*100;
    double savedValue = (saved/budget)*100;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.red,
              value: expenseValue,
              radius: 50,
              showTitle: false,
              borderSide: BorderSide(color: Colors.black, width: 1),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: savedValue,
              radius: 50,
              showTitle: false,
            ),
          ],
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, Map<String, dynamic> data) {
    bool hasData = data['budget'] > 0 || data['expenses'] > 0 || data['saved'] > 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            hasData
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Budget: \₱${data['budget']}", style: TextStyle(fontSize: 16, color: Colors.blue)),
                Text("Expenses: \₱${data['expenses']}", style: TextStyle(fontSize: 16, color: Colors.red)),
                Text("Saved: \₱${data['saved']}", style: TextStyle(fontSize: 16, color: Colors.green)),
                SizedBox(height: 10),
                _buildPieChart(data['budget'], data['expenses'], data['saved']),
                Text("Frequently Bought Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...data['frequentItems'].map<Widget>(
                      (item) => Text("- ${item['name']} (${item['percentage']}%)"),
                ).toList(),
              ],
            )
                : Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text("No data available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => onChanged(value));
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Budgy Financial Report"), backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown("Select Year", selectedYear,
                FinancialReportGenerator()._extractYears(widget.itemList), (value) {
                  selectedYear = value;
                  _calculateReports();
                }),

            _buildDataCard("Annual Report", annualData),
            Divider(),

            _buildDropdown("Select Month", selectedMonth, FinancialReportGenerator()._months, (value) {
              selectedMonth = value;
              _calculateReports();
            }),

            _buildDataCard("Monthly Report", monthlyData),
            Divider(),

            _buildDropdown("Select Week", selectedWeek, FinancialReportGenerator()._weeks, (value) {
              selectedWeek = value;
              _calculateReports();
            }),

            _buildDataCard("Weekly Report", weeklyData),
            Divider(),

            _buildDropdown("Select Day", selectedDay, _getDaysInMonth(), (value) {
              selectedDay = value;
              _calculateReports();
            }),

            _buildDataCard("Daily Report", dailyData),
          ],
        ),
      ),
    );
  }
}
