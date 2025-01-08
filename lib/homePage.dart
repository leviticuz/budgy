import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_details.dart';
import 'homeTab.dart';
import 'createList.dart';
import 'seachBarOut.dart';
import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Item> itemList = [];
  int _selectedIndex = 0;
  Map<String, int> frequentlyBoughtItems = {};

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load saved items on app start
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

  void _addItemToList(String title, double budget, DateTime date) {
    setState(() {
      itemList.add(Item(
        title: title,
        budget: budget,
        date: date,
        items: [],
      ));
      _saveItems(); // Save items after adding
      _selectedIndex = 0; // Redirect back to HomeTab
    });
  }

  void _deleteItem(Item item) {
    setState(() {
      itemList.remove(item);
      _saveItems(); // Save items after deleting
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

  // Budget Validation Method
  void _validateBudget() {
    String budgetText = _budgetController.text.trim();
    double? budget = double.tryParse(budgetText);

    // Check if the input is a valid number
    if (budget == null) {
      // Not a valid number
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid number for the budget'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Check if the budget is less than ₱100
    if (budget < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget must be at least ₱100')),
      );
      return;
    }

    // Check if the budget exceeds 7 digits (greater than 9,999,999)
    if (budget > 9999999) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget cannot exceed ₱9,999,999')),
      );
      return;
    }

    // If all checks pass, proceed to add the item
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
          onDatePicked: (pickedDate) {
            setState(() {
              _selectedDate = pickedDate;
            });
          },
          onSelectDate: () {
            _selectDate(context);
          },
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
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _selectedIndex == 1
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        )
            : null,
        actions: _selectedIndex == 1
            ? [
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty ) {
                if(
                _budgetController.text.isNotEmpty){
                  _validateBudget();
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget is required'),
                      duration: Duration(seconds:1),
                    ),

                  );
                  return;
                }
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Title is required'),
                      duration: Duration(seconds:1)),
                );
                return;
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}