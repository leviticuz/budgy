import 'package:shared_preferences/shared_preferences.dart';
import 'package:Budgy/user_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dummyItems.dart';
import 'searchBarIn.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AddItemScreen extends StatefulWidget {
  final Function(String, double, int) onAddItem;
  final String? initialName;
  final double? initialPrice;
  final int? initialQuantity;
  final double budget;
  final Item? selectedItem;
  final double currentTotalCost;

  AddItemScreen({
    required this.onAddItem,
    this.initialName,
    this.initialPrice,
    this.initialQuantity,
    required this.budget,
    this.selectedItem,
    required this.currentTotalCost,
  });

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {

  final DatabaseService _databaseService = DatabaseService.instance;

  late TextEditingController _productController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  String? _productError;
  String? _priceError;
  String? _quantityError;

  bool _isProductManuallyEntered = false;
  bool _isPriceManuallyEntered = false;

  @override
  void initState() {
    super.initState();

    _productController = TextEditingController(text: widget.initialName ?? '');
    _priceController = TextEditingController(text: widget.initialPrice != null
        ? NumberFormat("#,##0.00").format(widget.initialPrice)
        : '');
    _quantityController = TextEditingController(text: widget.initialQuantity?.toString() ?? '');

    _productController.addListener(() {
      setState(() {
        _isProductManuallyEntered = true;
      });
    });

    _priceController.addListener(() {
      setState(() {
        _isPriceManuallyEntered = true;
      });
    });

    if (widget.selectedItem != null) {
      _productController.text = widget.selectedItem!.item_name!;
      _priceController.text = widget.selectedItem!.item_price.toString();
      _quantityController.text = '1';

      _isProductManuallyEntered = false;
      _isPriceManuallyEntered = false;
    }
  }

  // Save item to SharedPreferences
  /*Future<void> _saveItemToPreferences(String name, double price, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('savedItems');

    List<Map<String, dynamic>> itemList = [];
    if (storedData != null) {
      itemList = List<Map<String, dynamic>>.from(jsonDecode(storedData));
    }

    bool ifItem = false;
    for (var item in itemList) {
      if (item['name'] == name) {
        item['quantity'] += quantity;
        ifItem = true;
        break;
      }
    }

    if (!ifItem) {
      itemList.add({'name': name, 'price': price, 'quantity': quantity});
    }

    await prefs.setString('savedItems', jsonEncode(itemList));
  }*/

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning!"),
          content: Text("Adding this item would exceed your set budget.\nWould you like to continue?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                double price = double.parse(_priceController.text.replaceAll(',', ''));
                int quantity = int.parse(_quantityController.text);
                widget.onAddItem(_productController.text, price, quantity);
                /*_saveItemToPreferences(_productController.text, price, quantity);*/
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Yes", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: Colors.black,
                elevation: 6,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: Colors.black,
                elevation: 6,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5BB7A6),
        title: Text(widget.initialName != null ? 'Edit Item' : 'Add New Item',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search), onPressed: () {  },
           /* onPressed: () async {
              final selectedItem = await Navigator.push<Item>(
                context,
                MaterialPageRoute(
                  builder: (context) => const Searchbar(listTitle: ""),
                ),
              );

              if (selectedItem != null) {
                setState(() {
                  if (selectedItem.item_cost != null && selectedItem.item_cost != 'n/a') {
                    _priceController.text = selectedItem.item_cost.toString();
                  } else {
                    _priceController.text = selectedItem.item_price.toString();
                  }
                  _productController.text = selectedItem.item_name!;
                  _quantityController.text = '1';
                });
              }
            },*/
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: EdgeInsets.all(19.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _productController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: InputBorder.none,
                        errorText: _productError,
                      ),
                      enabled: true,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (₱)',
                        border: InputBorder.none,
                        errorText: _priceError,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                      ],
                      enabled: true,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 19),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: InputBorder.none,
                        errorText: _quantityError,
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _productError = null;
                      _priceError = null;
                      _quantityError = null;
                    });

                    if (_productController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty) {
                      double price = double.parse(_priceController.text.replaceAll(',', ''));
                      int quantity = int.parse(_quantityController.text);
                      double total = price * quantity;
                      double newTotalCost = widget.currentTotalCost + total;
                      String name = _productController.text;

                      bool itemExists = await _databaseService.checkItemExistsInFirebase(name, price);

                      if (newTotalCost > widget.budget) {
                        _showWarningDialog();
                      } else {
                        widget.onAddItem(_productController.text, price, quantity);
                        /*_saveItemToPreferences(name, price, quantity);*/
                        Navigator.pop(context);
                      }

                      if (!itemExists) {
                        try {
                          await _databaseService.addItem(name, price);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Item has been added successfully'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add item: $e'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }

                    } else {
                      if (_productController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item Name is required'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else if (_priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item price is required'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else if (_quantityController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item Quantity is required'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    widget.initialName != null ? 'Save Changes' : 'Add Item',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
