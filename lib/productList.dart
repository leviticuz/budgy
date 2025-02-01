import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'add_item.dart';
import 'item_details.dart';
import 'searchBarIn.dart';

class ProductListScreen extends StatefulWidget {
  final Item item;

  ProductListScreen({required this.item});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Item> _itemList;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');
    if (itemListJson != null) {
      final List<dynamic> decoded = jsonDecode(itemListJson);
      setState(() {
        _itemList = decoded.map((json) => Item.fromJson(json)).toList();
      });
    } else {
      _itemList = [];
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      for (var item in widget.item.items) {
        item.isChecked = _selectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text('${widget.item.title}'),
      ),
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleSelectAll,
                ),
                Text("Select All Items"), //Select all Items in the list<3
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.item.items.length,
                itemBuilder: (context, index) {
                  final product = widget.item.items[index];
                  return ListTile(
                    leading: Checkbox(
                      value: product.isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          product.isChecked = value ?? false;
                        });
                      },
                    ),
                    title: Text(product.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
