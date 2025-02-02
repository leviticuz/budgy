import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_details.dart';
import 'homeTab.dart';
import 'createList.dart';
import 'seachBarOut.dart';
import 'dashboard.dart';
import 'shared_prefs_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'notifications_screen.dart';

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
  DateTime? _lastPressedTime;
  Map<String, int> frequentlyBoughtItems = {};
  bool _isWeekly = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = jsonEncode(
        itemList.map((item) => item.toJson()).toList());
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

  void _addItemToList(String title, double budget, DateTime date, bool isWeekly) async {
    await SharedPrefsHelper.saveBudget(budget, date);

    setState(() {
      itemList.add(Item(
        title: title,
        budget: budget,
        date: date,
        items: [],
        selectedDate: DateTime.now(),
        creationDate: DateTime.now(),
        weekly: isWeekly, // Pass isWeekly
      ));
      _saveItems();
      _selectedIndex = 0;
    });
  }

  void _deleteItem(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to permanently delete this list?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  _loadItems();
                });
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                String key = '${DateFormat('yyyy-MM-dd').format(
                    item.date)}_budget';
                double budget = item.budget;
                double? currentBudget = prefs.getDouble(key);

                if (currentBudget != null) {
                  double updatedBudget = currentBudget - budget;

                  if (updatedBudget == 0) {
                    await prefs.remove(key);
                  } else {
                    await prefs.setDouble(key, updatedBudget);
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.title} deleted'),
                  ),
                );
                setState(() {
                  itemList.remove(item); // Delete the item
                  _saveItems(); // Save updated list
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Delete", style: TextStyle(color: Color(0xFFb8181e)),),
            ),
          ],
        );
      },
    );
  }

  void _editItem(Item item) async {
    double originalBudget = item.budget;
    DateTime originalDate = item.date;

    final updatedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateTab(
              titleController: TextEditingController(text: item.title),
              budgetController: TextEditingController(
                  text: item.budget.toStringAsFixed(2)),
              dateController: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(item.date)),
              selectedDate: item.date,
              onDatePicked: (pickedDate) =>
                  setState(() => item.date = pickedDate),
              onSelectDate: () => _selectDate(context),
              isNewList: false,
              isWeekly: item.weekly,
            ),
      ),
    );

    if (updatedItem != null) {
      final prefs = await SharedPreferences.getInstance();
      const String _budgetKey = "_budget";

      double newBudget = updatedItem.budget;
      DateTime newDate = updatedItem.date;

      int index = itemList.indexWhere((i) => i.title == item.title);
      if (index != -1) {
        itemList[index] = updatedItem;
      }

      await _saveItems();

      double finalBudget = newBudget - originalBudget;

      if (originalDate != newDate) {
        await SharedPrefsHelper.saveBudget(newBudget, newDate);

        String monthKey = "${originalDate.year}-${originalDate.month.toString()
            .padLeft(2, '0')}-${originalDate.day.toString().padLeft(2, '0')}";
        double existingBudget = prefs.getDouble("$monthKey$_budgetKey") ?? 0.0;
        double saveBudget = existingBudget + finalBudget;

        if (saveBudget == 0) {
          await prefs.remove("$monthKey$_budgetKey");
        } else {
          await prefs.setDouble("$monthKey$_budgetKey", saveBudget);
        }
      } else {
        await SharedPrefsHelper.saveBudget(finalBudget, originalDate);
      }

      setState(() {});
    }
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

  Future<bool> _confirmDateBeforeCreate(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.amber,
                ),
                SizedBox(width: 8),
                Text('Confirm Date'),
              ],
            ),
            content: Row(
              children: [
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Are you sure the date is correct? It cannot be changed in the future.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Confirm"),
              ),
            ],
          ),
    ) ?? false;
  }


  void _validateBudget() async {
    String budgetText = _budgetController.text.trim();
    double? budget = double.tryParse(budgetText);

    if (budget == null || budget < 100 || budget > 10000) {
      String message = budget == null
          ? 'Please enter a valid number for the budget'
          : budget < 100
          ? 'Budget must be at least ₱100'
          : 'Budget cannot exceed ₱10,000';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 1)),
      );
      return;
    }

    final confirm = await _confirmDateBeforeCreate(context);
    if (!confirm) return;

    _addItemToList(_titleController.text, budget, _selectedDate, _isWeekly);
  }

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(
            itemList: itemList, onDelete: _deleteItem, onEdit: _editItem);
      case 1:
        return CreateTab(
          titleController: _titleController,
          budgetController: _budgetController,
          dateController: _dateController,
          selectedDate: _selectedDate,
          onDatePicked: (pickedDate) =>
              setState(() => _selectedDate = pickedDate),
          onSelectDate: () => _selectDate(context),
          isNewList: true,
          isWeekly: _isWeekly,
        );
      case 2:
        return Seachbarout();
      case 3:
        return Dashboard(frequentlyBoughtItems: frequentlyBoughtItems);
      default:
        return HomeTab(
            itemList: itemList, onDelete: _deleteItem, onEdit: _editItem);
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex == 0) {
      final now = DateTime.now();
      if (_lastPressedTime == null || now.difference(_lastPressedTime!) > Duration(seconds: 2)) {
        Fluttertoast.showToast(
          msg: "Press back button again to exit",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
        _lastPressedTime = now;
        return Future.value(false);
      } else {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      }
    }
    setState(() {
      _selectedIndex = 0;
    });
    return Future.value(false);
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press here
      child: Scaffold(
        appBar: _selectedIndex != 2 && _selectedIndex != 3
            ? AppBar(
          backgroundColor: Color(0xFF5BB7A6),
          title: Text(
            _selectedIndex == 1 ? 'New List' : 'Lists',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            if (_selectedIndex != 1)
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // Navigate to the NotificationsScreen when the bell icon is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsScreen()),
                  );
                },
              ),
            if (_selectedIndex == 1)
              TextButton(
                onPressed: () {
                  if (_titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Title is required'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    return;
                  }
                  if (_budgetController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Budget is required'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    return;
                  }
                  _validateBudget();
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
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
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: 'Create'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
          ],
        ),
      ),
    );
  }
}
