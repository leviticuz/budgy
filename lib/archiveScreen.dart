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

  Future<void> _deleteItem(int index) async {
    bool confirmDelete = await _showDeleteConfirmationDialog();
    if (!confirmDelete) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      archivedItems.removeAt(index);
    });

    List<String> updatedArchive =
    archivedItems.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList('archivedItems', updatedArchive);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Item deleted")),
    );
  }

  Future<void> _clearArchive() async {
    bool confirmClear = await _showClearArchiveDialog();
    if (!confirmClear) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      archivedItems.clear();
    });

    await prefs.remove('archivedItems');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Archive cleared")),
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Item"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  Future<bool> _showClearArchiveDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Clear Archive"),
          content: Text("Are you sure you want to delete all archived items?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Clear"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ??
        false;
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
        actions: [
          if (archivedItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.white),
              onPressed: _clearArchive,
            ),
        ],
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
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteItem(index),
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
