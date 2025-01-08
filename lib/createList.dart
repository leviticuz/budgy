import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTab extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController budgetController;
  final TextEditingController dateController;
  final DateTime selectedDate;
  final Function(DateTime) onDatePicked;
  final VoidCallback onSelectDate;
  final bool isNewList;

  CreateTab({
    required this.titleController,
    required this.budgetController,
    required this.dateController,
    required this.selectedDate,
    required this.onDatePicked,
    required this.onSelectDate,
    required this.isNewList,
  });

  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  @override
  void initState() {
    super.initState();
    if (!widget.isNewList) {
      _loadData();
    }
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final data = await loadDataFromSharedPreferences(widget.selectedDate);
    if (data != null) {
      widget.titleController.text = data['title'];
      widget.budgetController.text = data['budget'].toString();
      widget.dateController.text = widget.selectedDate.toLocal().toString().split(' ')[0];
    }
  }

  // Save data to SharedPreferences
  Future<void> saveDataToSharedPreferences(
      String title, double budget, DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();

    // Format the date as a string (e.g., 'yyyy-MM-dd')
    String dateKey = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    Map<String, dynamic> data = {
      'title': title,
      'budget': budget,
    };

    await prefs.setString(dateKey, jsonEncode(data));
  }

  // Load data from SharedPreferences
  Future<Map<String, dynamic>?> loadDataFromSharedPreferences(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();

    // Format the date as a string (e.g., 'yyyy-MM-dd')
    String dateKey = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    String? jsonString = prefs.getString(dateKey);

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;  // If no data exists for the selected date
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNewList) {
      widget.titleController.clear();
      widget.budgetController.clear();
    }

    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(19.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Title Input Field
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: widget.titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Date Input Field
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.dateController,
                              decoration: InputDecoration(
                                labelText: 'Pick Date',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime today = DateTime.now();
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: today,
                                firstDate: today,
                                lastDate: DateTime(today.year + 7),
                              );
                              if (selectedDate != null && selectedDate != widget.selectedDate) {
                                widget.dateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format date as needed
                                widget.onDatePicked(selectedDate);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    // Budget Input Field
                    Container(
                      margin: EdgeInsets.only(bottom: 19),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: widget.budgetController,
                            decoration: InputDecoration(
                              labelText: 'Budget (₱)',
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                            ],
                          ),
                          Text(
                            'Minimum budget is ₱100',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Predefined Budget Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [100, 500, 1000, 5000, 8000, 10000].map((price) {
                        return GestureDetector(
                          onTap: () {
                            widget.budgetController.text = price.toString();
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              width: 125,
                              child: Center(
                                child: Text(
                                  '₱$price',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
