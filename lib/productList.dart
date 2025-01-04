import 'package:flutter/material.dart';
import 'add_item.dart';
import 'item_details.dart';

class ProductListScreen extends StatefulWidget {
  final Item item;

  ProductListScreen({required this.item});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

Map<String, int> frequentlyBoughtItems = {};

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Map<String, double>> monthlyData;

  @override
  void initState() {
    super.initState();
    monthlyData = List.generate(
      12,
          (index) => {'spending': 0.0, 'budget': widget.item.budget},
    );
  }

  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
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
              if (frequentlyBoughtItems.containsKey(itemName)) {
                frequentlyBoughtItems[itemName] = frequentlyBoughtItems[itemName]! + quantity;
              } else {
                frequentlyBoughtItems[itemName] = quantity;
              }
            });

            final int month = DateTime.now().month - 1;
            setState(() {
              monthlyData[month]['spending'] =
                  (monthlyData[month]['spending'] ?? 0.0) +
                      (itemPrice * quantity);
            });
          },
        ),
      ),
    );
  }

  double _calculateTotalCost() {
    return widget.item.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
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
            onPressed: _navigateToAddItemScreen,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: widget.item.items.length,
                itemBuilder: (context, index) {
                  final product = widget.item.items[index];
                  return Card(
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
                          fontSize: 18,
                          decoration: product.isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text('Price: ₱${product.price.toStringAsFixed(2)}'),
                      trailing: Text('Qty: ${product.quantity}', style: TextStyle(fontSize: 16)),
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
                    color: isOverBudget ? Colors.red : Colors.teal.shade100,
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
