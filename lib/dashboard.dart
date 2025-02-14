import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bar.dart';
import 'report.dart';

class Dashboard extends StatefulWidget {
  final Map<String, int> frequentlyBoughtItems;

  Dashboard({Key? key, required this.frequentlyBoughtItems}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  Map<String, int> frequentlyBoughtItems = {};
  Map<String, int> monthlyFrequentlyBoughtItems = {};
  DateTime selectedDate = DateTime.now();
  late TabController _tabController;
  String? selectedMonth;

  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = months[selectedDate.month - 1];
    _tabController = TabController(length: 2, vsync: this);
    _loadFrequentlyBoughtItems();
    _loadMonthlyFrequentlyBoughtItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFrequentlyBoughtItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('itemList');

    if (storedData != null) {
      final List<dynamic> itemListData = jsonDecode(storedData);
      Map<String, int> updatedFrequentlyBoughtItems = {};

      for (var item in itemListData) {
        List<dynamic> items = item['items'];
        for (var product in items) {
          String itemName = product['name'];
          int quantity = product['quantity'];
          updatedFrequentlyBoughtItems.update(
              itemName, (value) => value + quantity, ifAbsent: () => quantity);
        }
      }
      setState(() {
        frequentlyBoughtItems = updatedFrequentlyBoughtItems;
      });
    }
  }

  Future<void> _loadMonthlyFrequentlyBoughtItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('itemList');

    if (storedData != null) {
      final List<dynamic> itemListData = jsonDecode(storedData);
      List<Map<String, dynamic>> filteredItems = [];

      for (var item in itemListData) {
        String itemDate = item['date'];
        DateTime itemDateTime = DateTime.parse(itemDate);
        if (selectedMonth == null) return;
        if (itemDateTime.year == selectedDate.year &&
            itemDateTime.month == (months.indexOf(selectedMonth!) + 1)) {
          filteredItems.add(item);
        }
      }

      Map<String, int> updatedMonthlyItems = {};
      for (var item in filteredItems) {
        List<dynamic> items = item['items'];
        for (var product in items) {
          String itemName = product['name'];
          int quantity = product['quantity'];
          updatedMonthlyItems.update(
              itemName, (value) => value + quantity, ifAbsent: () => quantity);
        }
      }

      setState(() {
        monthlyFrequentlyBoughtItems = updatedMonthlyItems;
      });
    }
  }

  List<BarChartGroupData> _generateBarData(Map<String, int> dataMap) {
    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top10Entries = sortedEntries.take(10);

    return top10Entries.map((entry) {
      int index = top10Entries.toList().indexOf(entry);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildBarChart(Map<String, int> dataMap) {
    if (dataMap.isEmpty) {
      return Center(child: Text("No available data", style: TextStyle(color: Color(0xFF91180F)),),);
    }

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dataMap.values.isNotEmpty ? dataMap.values.reduce((a, b) => a > b ? a : b) + 5 : 10).toDouble(),
          barGroups: _generateBarData(dataMap),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 5)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < dataMap.keys.length) {
                    String itemName = dataMap.keys.elementAt(index);
                    List<String> words = itemName.split(' ');
                    String displayName = words.take(3).join(' ');
                    return RotatedBox(
                      quarterTurns: 1,
                      child: SizedBox(
                        width: 60,
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }
                  return Text('');
                },
                reservedSize: 80,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFF5BB7A6),
        title: Text("Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.flag),
            onPressed: () {
              FinancialReportGenerator().showFinancialReport(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 330,
                  height: double.infinity,
                  constraints: BoxConstraints(minHeight: 300, maxHeight: 500),
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
                    children: [
                      SizedBox(height: 10),
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: "General"),
                          Tab(text: "Monthly"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBarChart(frequentlyBoughtItems),
                            Column(
                              children: [
                                DropdownButton<String>(
                                  value: selectedMonth,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedMonth = newValue;
                                      _loadMonthlyFrequentlyBoughtItems();
                                    });
                                  },
                                  items: months.map((String month) {
                                    return DropdownMenuItem<String>(
                                        value: month, child: Text(month));
                                  }).toList(),
                                ),
                                Expanded(child: _buildBarChart(monthlyFrequentlyBoughtItems)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                barChart(selectedDate: selectedDate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
