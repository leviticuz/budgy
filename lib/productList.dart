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
  void _navigateToAddItemScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          onAddItem: (String itemName, double itemPrice, int quantity) {
            setState(() {
              widget.item.items.add(
                ItemDetail(
                  name: itemName,
                  quantity: quantity,
                  isChecked: false,
                  price: itemPrice,
                ),
              );
            });
          },
          budget: widget.item.budget,
        ),
      ),
    );
  }

  void _navigateToEditItemScreen(int index, ItemDetail product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          onAddItem: (String newName, double newPrice, int newQuantity) {
            setState(() {
              widget.item.items[index] = ItemDetail(
                name: newName,
                price: newPrice,
                quantity: newQuantity,
                isChecked: product.isChecked,
              );
            });
          },
          initialName: product.name,
          initialPrice: product.price,
          initialQuantity: product.quantity,
          budget: widget.item.budget,
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
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
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
                            fontSize: 18,
                            decoration: product.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: ₱${product.price.toStringAsFixed(2)}'),
                            Text(
                              'Cost: ₱${(product.price * product.quantity).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Qty: ${product.quantity}',
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                _navigateToEditItemScreen(index, product);
                              },
                            ),
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
