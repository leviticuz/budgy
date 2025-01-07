import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'productList.dart';
import 'item_details.dart';

class HomeTab extends StatelessWidget {
  final List<Item> itemList;
  final Function(Item) onDelete;

  HomeTab({required this.itemList, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        final item = itemList[index];
        return Dismissible(
          key: Key(item.title),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            onDelete(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.title} deleted'),
              ),
            );
          },
          background: Container(
            margin: EdgeInsets.symmetric(vertical: 8), // Add margin here
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16), // Set the same radius as the card
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
          ),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(item.title, style: TextStyle(fontSize: 18)),
              subtitle: Text(
                'Budget: ₱${item.budget.toStringAsFixed(2)}\nDate: ${DateFormat('yyyy-MM-dd').format(item.date)}',
              ),
              trailing: Stack(
                clipBehavior: Clip.none,  // Allow the text to overflow
                children: [
                  // Reduced opacity text
                  Positioned(
                    bottom: 0,
                    right: 30,
                    child: Opacity(
                      opacity: 0.5,  // Reduced opacity
                      child: Text(
                        "Slide to delete",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey, // You can choose any color you want
                        ),
                      ),
                    ),
                  ),
                  // Arrow icon
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
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
    );
  }
}
