import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'add_item.dart';
import 'item_details.dart';

class ProductListScreen extends StatefulWidget {
  final Item item;

  ProductListScreen({required this.item});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Item> _itemList;

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
      _itemList = decoded.map((json) => Item.fromJson(json)).toList();
    } else {
      _itemList = [];
    }
    setState(() {});
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = jsonEncode(_itemList.map((item) => item.toJson()).toList());
    await prefs.setString('itemList', itemListJson);
  }

  void _updateItemInList(Item updatedItem) {
    final index = _itemList.indexWhere((item) => item.title == updatedItem.title);
    if (index != -1) {
      _itemList[index] = updatedItem;
      _saveItems();
    }
  }

  double _calculateTotalCost() {
    return widget.item.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          onAddItem: (String itemName, double itemPrice, int quantity) {
            bool itemExists = false;
            for (var existingItem in widget.item.items) {
              if (existingItem.name == itemName) {
                existingItem.quantity += quantity;
                itemExists = true;
                break;
              }
            }
            if (!itemExists) {
              widget.item.items.add(ItemDetail(name: itemName, quantity: quantity, isChecked: false, price: itemPrice));
            }
            _updateItemInList(widget.item);
            _updateFrequentlyBoughtItems(itemName);
            _saveSpendingForMonth(_calculateTotalCost(), widget.item.date);
            setState(() {});
          },
          budget: widget.item.budget,
          currentTotalCost: _calculateTotalCost(),
        ),
      ),
    );
  }

  Future<void> _updateFrequentlyBoughtItems(String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    final frequentlyBoughtItems = Map<String, int>.from(jsonDecode(prefs.getString('frequentlyBoughtItems') ?? '{}'));
    frequentlyBoughtItems[itemName] = (frequentlyBoughtItems[itemName] ?? 0) + 1;
    await prefs.setString('frequentlyBoughtItems', jsonEncode(frequentlyBoughtItems));
  }

  Future<void> _saveSpendingForMonth(double spending, DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    final monthKey = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";
    final currentMonthSpending = prefs.getDouble("${monthKey}_spending") ?? 0.0;
    await prefs.setDouble("${monthKey}_spending", currentMonthSpending + spending);
  }

  @override
  Widget build(BuildContext context) {
    double totalCost = _calculateTotalCost();
    double balance = widget.item.budget - totalCost;
    bool isOverBudget = totalCost > widget.item.budget;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text(widget.item.title),
        actions: [IconButton(icon: Icon(Icons.add_circle_outline), onPressed: _navigateToAddItemScreen)],
      ),
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Column(
          children: [
            Text("Note: Slide to Delete", style: TextStyle(color: Colors.grey)),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: widget.item.items.length,
                itemBuilder: (context, index) {
                  final product = widget.item.items[index];
                  return Dismissible(
                    key: Key(product.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      widget.item.items.removeAt(index);
                      _updateItemInList(widget.item);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} deleted")));
                      setState(() {});
                    },
                    background: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: product.isChecked ? Colors.grey.shade200 : Colors.white,
                      child: ListTile(
                        leading: Checkbox(
                          value: product.isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              product.isChecked = value!;
                            });
                          },
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: product.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ₱${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 12)),
                            Text(
                              'Cost: ₱${(product.price * product.quantity).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        trailing: Text('Qty: ${product.quantity}', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget: ₱${widget.item.budget.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  Container(
                    decoration: BoxDecoration(
                      color: isOverBudget ? Colors.red : Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Balance: ₱${balance.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isOverBudget ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
