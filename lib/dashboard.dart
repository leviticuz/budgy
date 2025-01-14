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

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  Map<String, int> frequentlyBoughtItems = {};
  Map<String, int> monthlyFrequentlyBoughtItems = {};
  DateTime selectedDate = DateTime.now();
  int touchedIndex = -1;
  late TabController _tabController;

  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String? selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = months[selectedDate.month - 1];
    _loadFrequentlyBoughtItems();
    _loadMonthlyFrequentlyBoughtItems();
    _tabController = TabController(length: 2, vsync: this);
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
          updatedFrequentlyBoughtItems.update(itemName, (value) => value + quantity, ifAbsent: () => quantity);
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

          updatedMonthlyItems.update(itemName, (value) => value + quantity, ifAbsent: () => quantity);
        }
      }

      setState(() {
        monthlyFrequentlyBoughtItems = updatedMonthlyItems;
      });
    }
  }

  List<Widget> LegendItems(Map<String, int> dataMap) {
    return dataMap.entries.map((entry) {
      String itemName = entry.key.split(' ').take(3).join(' ') + '...';

      return Container(
        width: MediaQuery.of(context).size.width / 3 - 24,
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
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
            Expanded(
              child: Text(
                itemName,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double totalQuantity = frequentlyBoughtItems.values.fold(0, (sum, value) => sum + value);
    int totalMonthlyFrequency = monthlyFrequentlyBoughtItems.values.fold(0, (sum, value) => sum + value);

    List<PieChartSectionData> allTimeSections = frequentlyBoughtItems.entries.map((entry) {
      double percentage = (entry.value / totalQuantity) * 100;
      final isTouched = frequentlyBoughtItems.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      return PieChartSectionData(
        color: Colors.accents[frequentlyBoughtItems.keys.toList().indexOf(entry.key) % Colors.accents.length],
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();

    List<PieChartSectionData> monthlySections = monthlyFrequentlyBoughtItems.entries.map((entry) {
      double percentage = (entry.value / totalMonthlyFrequency) * 100;
      final isTouched = monthlyFrequentlyBoughtItems.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      return PieChartSectionData(
        color: Colors.accents[monthlyFrequentlyBoughtItems.keys.toList().indexOf(entry.key) % Colors.accents.length],
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFF5BB7A6),
        automaticallyImplyLeading: false,
        title: Text("Dashboard", style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Frequently Bought',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.black,
                        tabs: [
                          Tab(text: 'General'),
                          Tab(text: 'Monthly'),
                        ],
                      ),
                      SizedBox(
                        height: 350,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            frequentlyBoughtItems.isEmpty
                                ? Center(child: Text('No data available'))
                                : Column(
                              children: [
                                Expanded(
                                  child: AspectRatio(
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
                                        sections: allTimeSections,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: LegendItems(frequentlyBoughtItems),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                // Dropdown remains visible even if no data
                                DropdownButton<String>(
                                  value: selectedMonth,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedMonth = newValue;
                                      _loadMonthlyFrequentlyBoughtItems(); // Reload data based on selected month
                                    });
                                  },
                                  items: months.map((month) {
                                    return DropdownMenuItem<String>(
                                      value: month,
                                      child: Text(month),
                                    );
                                  }).toList(),
                                ),
                                monthlyFrequentlyBoughtItems.isEmpty
                                    ? Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text('No data available for this month', style: TextStyle(fontSize: 16, color: Colors.red)),
                                )
                                    : Expanded(
                                  child: AspectRatio(
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
                                        sections: monthlySections,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Wrap(
                                    spacing: 8.0,  // Horizontal gap between items
                                    runSpacing: 4.0,  // Vertical gap between rows
                                    children: LegendItems(monthlyFrequentlyBoughtItems),
                                  ),
                                ),
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

