import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dummyItems.dart';
import 'searchBarIn.dart';



class AddItemScreen extends StatefulWidget {
  final Function(String, double, int) onAddItem;
  final Item? selectedItem;

  AddItemScreen({required this.onAddItem, this.selectedItem});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _productController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedItem != null) {
      _productController.text = widget.selectedItem!.item_name!;
      _priceController.text = widget.selectedItem!.item_price.toString();
      _quantityController.text = '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selectedItem = await Navigator.push<Item>(
                context,
                MaterialPageRoute(
                  builder: (context) => const Searchbar(),
                ),
              );
              if (selectedItem != null) {
                setState(() {
                  _productController.text = selectedItem.item_name!;
                  _priceController.text = selectedItem.item_price.toString();
                  _quantityController.text = '1';
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price (₱)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_productController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty) {
                      double price = double.parse(_priceController.text);
                      int quantity = int.parse(_quantityController.text);
                      widget.onAddItem(_productController.text, price, quantity);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add Item', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
