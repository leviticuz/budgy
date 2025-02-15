import 'package:Budgy/list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'productList.dart';
import 'item_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeTab extends StatefulWidget {
  final Function(Item) onDelete;
  final Function(Item) onEdit;

  HomeTab({required this.onDelete, required this.onEdit});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late List<Item> itemList = [];

  @override
  void initState() {
    super.initState();
    _loadItemList();
  }

  // Load items from SharedPreferences
  Future<void> _loadItemList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemListJson = prefs.getString('itemList');

    if (itemListJson != null) {
      List<dynamic> decodedList = jsonDecode(itemListJson);
      setState(() {
        itemList = decodedList.map((json) => Item.fromJson(json)).toList();
      });
    }
  }


  void _archiveItem(Item item) async {
    // Remove from the list and save changes
    setState(() {
      itemList.remove(item);
    });

    // Save updated list to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('itemList', jsonEncode(itemList));

    // Optionally, move it to an "archivedItems" list
    List<String> archivedItems = prefs.getStringList('archivedItems') ?? [];
    archivedItems.add(jsonEncode(item));
    prefs.setStringList('archivedItems', archivedItems);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.title} archived")),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Separate lists based on 'weekly' value
    final List<Item> scheduledItems = itemList.where((item) => !item.weekly).toList();
    final List<Item> recurringItems = itemList.where((item) => item.weekly).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFB1E8DE),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              child: TabBar(
                indicatorColor: Colors.teal,
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Scheduled'),
                  Tab(text: 'Recurring'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Scheduled items
                  _buildItemList(scheduledItems),
                  // Recurring items
                  _buildItemList(recurringItems),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomUIPage()),
            );
            // Refresh the list once you return from CustomUIPage
            _loadItemList();  // Call _loadItemList() after returning
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Positioned at bottom-left
      ),
    );
  }

  Widget _buildItemList(List<Item> itemList) {
    if (itemList.isEmpty) {
      return Center(
        child: Text(
          "No items available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        Center(
          child: Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/LabeledLogo.png',
            ),
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            final item = itemList[itemList.length - 1 - index]; // Reverse order
            return Dismissible(
              key: Key(item.title),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                widget.onDelete(item); // Calls the onDelete function
              },
              background: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(item.title, style: TextStyle(fontSize: 18)),
                  subtitle: Text(
                    'Budget: ₱${item.budget.toStringAsFixed(2)}\nBudget Date: ${DateFormat('yyyy-MM-dd').format(item.date)}\nDate Created: ${DateFormat('yyyy-MM-dd').format(item.creationDate)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20),
                    offset: Offset(0, 30),
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit(item);
                      } else if (value == 'delete') {
                        widget.onDelete(item);
                      } else if (value == 'archive') {
                        _archiveItem(item);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      List<PopupMenuEntry<String>> menuItems = [
                        PopupMenuItem<String>(
                          value: 'edit',
                          height: 30,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            child: Text(
                              'Edit',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          height: 30,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            child: Text(
                              'Delete',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ];

                      // Add "Archive" option only for scheduled items
                      if (!item.weekly) {
                        menuItems.insert(
                          0,
                          PopupMenuItem<String>(
                            value: 'archive',
                            height: 30,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                              child: Text(
                                'Archive',
                                style: TextStyle(fontSize: 12, color: Color(0xFFb8181e)),
                              ),
                            ),
                          ),
                        );
                      }

                      return menuItems;
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(item: item),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
