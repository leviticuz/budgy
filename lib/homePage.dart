import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'item_details.dart';
import 'homeTab.dart';
import 'createList.dart';
import 'seachBarOut.dart';
import 'dashboard.dart';
import 'shared_prefs_helper.dart'; // Import helper class

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Item> itemList = [];
  int _selectedIndex = 0;
  Map<String, int> frequentlyBoughtItems = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = jsonEncode(itemList.map((item) => item.toJson()).toList());
    prefs.setString('itemList', itemListJson);
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');
    if (itemListJson != null) {
      final List<dynamic> decoded = jsonDecode(itemListJson);
      setState(() {
        itemList = decoded.map((json) => Item.fromJson(json)).toList();
      });
    }
  }

  void _addItemToList(String title, double budget, DateTime date) async {
    await SharedPrefsHelper.saveBudget(budget, date);

    setState(() {
      itemList.add(Item(
        title: title,
        budget: budget,
        date: date,
        items: [],
        selectedDate: DateTime.now(),
      ));
      _saveItems();
      _selectedIndex = 0; // Navigate back to Home after saving
    });
  }

  void _deleteItem(Item item) {
    setState(() {
      itemList.remove(item);
      _saveItems();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _validateBudget() {
    String budgetText = _budgetController.text.trim();
    double? budget = double.tryParse(budgetText);

    if (budget == null || budget < 100 || budget > 9999999) {
      String message = budget == null
          ? 'Please enter a valid number for the budget'
          : budget < 100
          ? 'Budget must be at least ₱100'
          : 'Budget cannot exceed ₱9,999,999';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 1)),
      );
      return;
    }

    _addItemToList(_titleController.text, budget, _selectedDate);
  }

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(itemList: itemList, onDelete: _deleteItem);
      case 1:
        return CreateTab(
          titleController: _titleController,
          budgetController: _budgetController,
          dateController: _dateController,
          selectedDate: _selectedDate,
          onDatePicked: (pickedDate) => setState(() => _selectedDate = pickedDate),
          onSelectDate: () => _selectDate(context),
          isNewList: true,
        );
      case 2:
        return Seachbarout();
      case 3:
        return Dashboard(frequentlyBoughtItems: frequentlyBoughtItems);
      default:
        return HomeTab(itemList: itemList, onDelete: _deleteItem);
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 2 && _selectedIndex != 3
          ? AppBar(
        backgroundColor: Color(0xFF5BB7A6),
        title: Text(
          _selectedIndex == 1 ? 'New List' : 'Lists',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _selectedIndex == 1
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedIndex = 0),
        )
            : null,
        actions: _selectedIndex == 1
            ? [
          TextButton(
            onPressed: () {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Title is required'), duration: Duration(seconds: 1)),
                );
                return;
              }
              if (_budgetController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget is required'), duration: Duration(seconds: 1)),
                );
                return;
              }
              _validateBudget();
            },
            child: Text(
              'Done',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ]
            : null,
      )
          : null,
      body: Container(
        color: Color(0xFFB1E8DE),
        child: _currentPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.teal.shade900,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
