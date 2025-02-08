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
        var matchedItem = decoded.firstWhere(
              (json) => json['title'] == widget.item.title,
          orElse: () => null,
        );

        if (matchedItem != null) {
          // Directly update widget.item.items instead of using a separate list
          widget.item.items = List<ItemDetail>.from(
            matchedItem['items'].map((jsonItem) => ItemDetail.fromJson(jsonItem)),
          );
        } else {
          widget.item.items = [];
        }
      });
    } else {
      setState(() {
        widget.item.items = [];
      });
    }
  }



  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = jsonEncode(
        _itemList.map((item) => item.toJson()).toList());
    prefs.setString('itemList', itemListJson);
  }

  void _updateItemInList(Item updatedItem) {
    setState(() {
      final index = _itemList.indexWhere((item) => item.title == updatedItem.title);
      if (index != -1) {
        _itemList[index] = updatedItem;
      } else {
        _itemList.add(updatedItem);
      }
      _saveItems(); // Save updated list
    });
  }

  double _calculateTotalCost() {
    return widget.item.items.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddItemScreen(
              onAddItem: (String itemName, double itemPrice, int quantity) {
                setState(() {
                  bool itemExists = false;
                  for (var existingItem in widget.item.items) {
                    if (existingItem.name == itemName) {
                      existingItem.quantity += quantity;
                      itemExists = true;
                      break;
                    }
                  }
                  if (!itemExists) {
                    widget.item.items.add(
                      ItemDetail(
                        name: itemName,
                        quantity: quantity,
                        isChecked: false,
                        price: itemPrice,
                      ),
                    );
                  }
                  _updateItemInList(widget.item);
                  _updateFrequentlyBoughtItems(itemName);
                  _saveSpendingForMonth(
                      _calculateTotalCost(), widget.item.date);
                });
              },
              budget: widget.item.budget,
              currentTotalCost: _calculateTotalCost(),
            ),
      ),
    );
  }

  void _showConfirmPriceDialog(ItemDetail product, int index) {
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Price"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Do you confirm the price for '${product.name}'?"),
              SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Update Price (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
            ),
            ElevatedButton(
              child: Text("Confirm"),
              onPressed: () {
                String enteredPrice = priceController.text.trim();
                if (enteredPrice.isNotEmpty) {
                  setState(() {
                    product.price = double.parse(enteredPrice);
                    _updateItemInList(widget.item); // Save updated price
                  });
                }
                setState(() {
                  product.isChecked = true; // Mark item as checked
                });
                _updateItemInList(widget.item); // Save to database
                Navigator.pop(context); // Close the modal
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _updateFrequentlyBoughtItems(String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('frequentlyBoughtItems');
    final String? monthlyData = prefs.getString('monthlyPurchases');

    Map<String, int> frequentlyBoughtItems = {};
    Map<String, Map<String, int>> monthlyPurchases = {};

    if (storedData != null) {
      frequentlyBoughtItems = Map<String, int>.from(jsonDecode(storedData));
    }
    if (monthlyData != null) {
      monthlyPurchases = Map<String, Map<String, int>>.from(
        jsonDecode(monthlyData).map(
              (key, value) => MapEntry(key, Map<String, int>.from(value)),
        ),
      );
    }

    frequentlyBoughtItems[itemName] =
        (frequentlyBoughtItems[itemName] ?? 0) + 1;

    String monthKey = "${DateTime
        .now()
        .year}-${DateTime
        .now()
        .month
        .toString()
        .padLeft(2, '0')}";
    monthlyPurchases[monthKey] = monthlyPurchases[monthKey] ?? {};
    monthlyPurchases[monthKey]![itemName] =
        (monthlyPurchases[monthKey]![itemName] ?? 0) + 1;

    prefs.setString('frequentlyBoughtItems', jsonEncode(frequentlyBoughtItems));
    prefs.setString('monthlyPurchases', jsonEncode(monthlyPurchases));
  }


  void _navigateToEditItemScreen(int index, ItemDetail product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddItemScreen(
              onAddItem: (String newName, double newPrice, int newQuantity) {
                setState(() {
                  widget.item.items[index] = ItemDetail(
                    name: newName,
                    price: newPrice,
                    quantity: newQuantity,
                    isChecked: product.isChecked,
                  );
                  _updateItemInList(widget.item);
                  _saveSpendingForMonth(
                      _calculateTotalCost(), widget.item.date);
                });
              },
              initialName: product.name,
              initialPrice: product.price,
              initialQuantity: product.quantity,
              budget: widget.item.budget,
              currentTotalCost: _calculateTotalCost(),
            ),
      ),
    );
  }

  Future<void> _saveSpendingForMonth(double spending,
      DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    String monthKey = "${selectedDate.year}-${selectedDate.month.toString()
        .padLeft(2, '0')}";
    double currentMonthSpending = prefs.getDouble(monthKey + "_spending") ??
        0.0;
    currentMonthSpending += spending;
    await prefs.setDouble(monthKey + "_spending", currentMonthSpending);
  }
  void _navigateToSearchBar(String listTitle) async {
    // Navigate to the Searchbar screen and pass listTitle as an argument
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Searchbar(listTitle: listTitle),  // Pass listTitle here
      ),
    );

    // After returning from Searchbar screen, reload the items and rebuild the widget
    setState(() {
      print('working...');
      _loadItems(); // This should trigger a rebuild of the widget and update the UI
    });
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
    double totalCost = _calculateTotalCost();
    double balance = widget.item.budget - totalCost;
    bool isOverBudget = totalCost > widget.item.budget;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text('${widget.item.title}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () async => _navigateToSearchBar(widget.item.title),
          ),
        ],
      ),
      body: widget.item.items.isEmpty
          ? GestureDetector(
        onTap:  () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Searchbar(listTitle: widget.item.title),  // Pass listTitle here
            ),
          );
          _loadItems();
        },
        child: Container(
          color: Color(0xFFB1E8DE),
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "Your list is empty. Tap anywhere to add an item.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      )
          : Container(
        color: Color(0xFFB1E8DE),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleSelectAll,
                ),
                Text("Select All Items"),
              ],
            ),
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
                      setState(() {
                        widget.item.items.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${product.name} deleted")),
                      );
                    },
                    background: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: product.isChecked ? Colors.grey.shade200 : Colors
                          .white,
                      child: ListTile(
                        leading: Checkbox(
                          value: product.isChecked,
                          onChanged: (bool? value) {
                            if (value == true) {
                              _showConfirmPriceDialog(product, index);
                            } else {
                              setState(() {
                                product.isChecked = false;
                                _updateItemInList(widget.item);
                              });
                            }
                          },
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: product.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ₱${product.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12)),
                            Text(
                              'Cost: ₱${(product.price * product.quantity)
                                  .toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Qty: ${product.quantity}',
                              style: TextStyle(fontSize: 14),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, size: 20),
                              offset: Offset(0, 30),
                              onSelected: (String value) {
                                if (value == 'edit') {
                                  _navigateToEditItemScreen(index, product);
                                } else if (value == 'delete') {
                                  setState(() {
                                    widget.item.items.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(
                                        "${product.name} deleted")),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    height: 30,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 8),
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 8),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(fontSize: 12,
                                            color: Color(0xFFb8181e)),
                                      ),
                                    ),
                                  ),
                                ];
                              },
                            )
                          ],
                        ),
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
                  Text('Budget: ₱${widget.item.budget.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16)),
                  Container(
                    decoration: BoxDecoration(
                      color: isOverBudget ? Colors.red : Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Balance: ₱${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.white : Colors.black,
                      ),
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
