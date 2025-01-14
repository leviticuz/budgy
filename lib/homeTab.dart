import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'productList.dart';
import 'item_details.dart';

class HomeTab extends StatelessWidget {
  final List<Item> itemList;
  final Function(Item) onDelete;
  final Function(Item) onEdit;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  HomeTab({required this.itemList, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/LabeledLogo.png',
            ),
          ),
        ),
        // List of items
        AnimatedList(
          key: _listKey,
          padding: EdgeInsets.all(16),
          initialItemCount: itemList.length,
          itemBuilder: (context, index, animation) {
            final item = itemList[itemList.length - 1 - index];
            return Dismissible(
              key: Key(item.title),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                onDelete(item);
              },
              background: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
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
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20),
                    offset: Offset(0, 30),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit(item);
                      } else if (value == 'delete') {
                        onDelete(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.title} deleted'),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'edit',
                          height: 30,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            child: Text(
                              'Delete',
                              style: TextStyle(fontSize: 12, color: Color(0xFFb8181e)),
                            ),
                          ),
                        ),
                      ];
                    },
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
        ),
      ],
    );
  }
}
