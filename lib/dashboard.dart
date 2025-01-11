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

  // Load all-time frequently bought items
  Future<void> _loadFrequentlyBoughtItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('frequentlyBoughtItems');
    if (storedData != null) {
      final Map<String, int> loadedData = Map<String, int>.from(jsonDecode(storedData));
      setState(() {
        frequentlyBoughtItems = loadedData;
      });
    }
  }

  // Load monthly frequently bought items, filter by selected month
  Future<void> _loadMonthlyFrequentlyBoughtItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('itemList'); // Fetching data using the correct key

    if (storedData != null) {
      // Decode the stored data into a list of items
      final List<dynamic> itemListData = jsonDecode(storedData);

      List<Map<String, dynamic>> filteredItems = [];
      for (var item in itemListData) {
        // Check if the item's date matches the selected month
        String itemDate = item['date']; // Example: "2025-01-11T19:16:47.200318"
        DateTime itemDateTime = DateTime.parse(itemDate);

        // Filter by the selected year and month
        if (itemDateTime.year == selectedDate.year &&
            itemDateTime.month == (months.indexOf(selectedMonth!) + 1)) {
          filteredItems.add(item);
        }
      }

      // Now process the filteredItems to count the frequencies
      Map<String, int> updatedMonthlyItems = {};

      for (var item in filteredItems) {
        List<dynamic> items = item['items']; // List of item details
        for (var product in items) {
          String itemName = product['name']; // Item name (e.g., 'Liberty Condensada')
          int quantity = product['quantity']; // Quantity purchased

          // Add quantity to the map, updating it based on the existing or new item
          updatedMonthlyItems.update(itemName, (value) => value + quantity, ifAbsent: () => quantity);
        }
      }

      setState(() {
        monthlyFrequentlyBoughtItems = updatedMonthlyItems; // Update the state with the new data
      });
    }
  }

  List<Widget> LegendItems(Map<String, int> dataMap) {
    return dataMap.entries.map((entry) {
      String itemName = entry.key.split(' ').take(3).join(' ') + '...';

      return Container(
        width: MediaQuery.of(context).size.width / 3 - 24, // Ensures 3 items per row
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0), // Reduced vertical margin
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
                overflow: TextOverflow.ellipsis, // Handles long names gracefully
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    int totalFrequency = frequentlyBoughtItems.values.fold(0, (sum, value) => sum + value);
    int totalMonthlyFrequency = monthlyFrequentlyBoughtItems.values.fold(0, (sum, value) => sum + value);

    List<PieChartSectionData> allTimeSections = frequentlyBoughtItems.entries.map((entry) {
      double percentage = (entry.value / totalFrequency) * 100;
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
                                // Show a message when there is no data for the selected month
                                monthlyFrequentlyBoughtItems.isEmpty
                                    ? Padding(
                                  padding: const EdgeInsets.all(16.0),
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

