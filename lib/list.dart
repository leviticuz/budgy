import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'item_details.dart';
import 'package:intl/intl.dart';

class CustomUIPage extends StatefulWidget {
  @override
  _CustomUIPageState createState() => _CustomUIPageState();
}

class _CustomUIPageState extends State<CustomUIPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool _isWeekly = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }


  // Save data to SharedPreferences
  void _saveData() async {
    if (titleController.text.isEmpty || budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    double? budget = double.tryParse(budgetController.text);
    if (budget == null || budget < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum budget is ₱100')),
      );
      return;
    }

    Item newItem = Item(
      title: titleController.text,
      budget: budget,
      date: _selectedDate,
      items: [],
      selectedDate: DateTime.now(),
      creationDate: DateTime.now(),
      weekly: _isWeekly,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Item> itemList = [];

    // Load existing list
    String? itemListString = prefs.getString('itemList');
    if (itemListString != null) {
      List<dynamic> decodedList = jsonDecode(itemListString);
      itemList = decodedList.map((item) => Item.fromJson(item)).toList();
    }

    // Add the new item to the list
    itemList.add(newItem);

    // Save updated list
    final itemListJson = jsonEncode(itemList.map((item) => item.toJson()).toList());
    prefs.setString('itemList', itemListJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('List Created Successfuly successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create List'),
        backgroundColor: Color(0xFF5BB7A6),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveData,
          ),
        ],
      ),
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
                    _buildInputField(titleController, 'Title'),
                    _buildDatePicker(),
                    _buildToggleSwitch(),
                    _buildInputField(budgetController, 'Budget (₱)'),
                    _buildBudgetButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool isReadOnly = false}) {
    return Container(
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
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        readOnly: isReadOnly,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
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
              controller: dateController,
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
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 7),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  dateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: EdgeInsets.only(bottom: 19),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_isWeekly ? "Repeat weekly" : "Never repeat", style: TextStyle(fontSize: 16)),
          Switch(
            value: _isWeekly,
            onChanged: (bool value) {
              setState(() {
                _isWeekly = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [100, 500, 1000, 5000, 8000, 10000].map((price) {
        return GestureDetector(
          onTap: () {
            budgetController.text = price.toString();
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
    );
  }
}
