import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'item_details.dart';

class ArchiveScreen extends StatefulWidget {
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Item> archivedItems = [];

  @override
  void initState() {
    super.initState();
    _loadArchivedItems();
  }

  Future<void> _loadArchivedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? archivedListJson = prefs.getStringList('archivedItems');

    if (archivedListJson != null) {
      setState(() {
        archivedItems = archivedListJson
            .map((json) => Item.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  Future<void> _restoreItem(Item item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove item from archive
    setState(() {
      archivedItems.remove(item);
    });

    // Update archived list in SharedPreferences
    List<String> updatedArchive = archivedItems.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList('archivedItems', updatedArchive);

    // Fetch and safely decode `itemList`
    String? itemListJson = prefs.getString('itemList');
    List<Item> itemList = [];

    if (itemListJson != null) {
      List<dynamic> decodedList = jsonDecode(itemListJson);
      itemList = decodedList.map((json) => Item.fromJson(json)).toList();
    }

    // Append restored item
    itemList.add(item);

    // Save back as a **JSON string** (to maintain correct format)
    await prefs.setString('itemList', jsonEncode(itemList));

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.title} restored")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFF5BB7A6),
        title: Text(
          'Archive',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: archivedItems.isEmpty
          ? _buildEmptyArchive()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: archivedItems.length,
        itemBuilder: (context, index) {
          final item = archivedItems[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(item.title, style: TextStyle(fontSize: 18)),
              subtitle: Text(
                'Budget: ₱${item.budget.toStringAsFixed(2)}\n'
                    'Budget Date: ${DateFormat('yyyy-MM-dd').format(item.date)}\n'
                    'Date Created: ${DateFormat('yyyy-MM-dd').format(item.creationDate)}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyArchive() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'You currently have no archived items',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
