import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'homeTab.dart';
import 'createList.dart';
import 'item_details.dart';
import 'productList.dart';
import 'seachBarOut.dart';
import 'dashboard.dart';



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

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addItemToList(String title, double budget, DateTime date) {
    setState(() {
      itemList.add(Item(
        title: title,
        budget: budget,
        date: date,
        items: [],
      ));
      _selectedIndex = 0;
    });
  }

  void _deleteItem(Item item) {
    setState(() {
      itemList.remove(item);
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

  @override
  Widget build(BuildContext context) {
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
          );
        case 2:
          return Seachbarout();
        case 3:
          return Dashboard(frequntlyBoughtItems: frequntlyBoughtItems);
        default:
          return HomeTab(itemList: itemList, onDelete: _deleteItem);
      }
    }

    return Scaffold(
      appBar: _selectedIndex != 2 && _selectedIndex != 3
          ? AppBar(
        backgroundColor: const Color(0xFF5BB7A6),
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
              if (_titleController.text.isNotEmpty &&
                  _budgetController.text.isNotEmpty) {
                double budget = double.parse(_budgetController.text);
                _addItemToList(
                    _titleController.text, budget, _selectedDate);
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ] : null,
      )
      :null,
      body: Container(
      color: Color(0xFFB1E8DE),
      child: _currentPage(),
      ),
      //   child: _selectedIndex == 0
      //       ? HomeTab(itemList: itemList, onDelete: _deleteItem)
      //       : CreateTab(
      //     titleController: _titleController,
      //     budgetController: _budgetController,
      //     dateController: _dateController,
      //     selectedDate: _selectedDate,
      //     onDatePicked: (pickedDate) {
      //       setState(() {
      //         _selectedDate = pickedDate;
      //       });
      //     },
      //     onSelectDate: () {
      //       _selectDate(context);
      //     },
      //   ),
      // ),
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
