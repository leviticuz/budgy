import 'package:Budgy/dummyItems.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:Budgy/user_db.dart';
import 'package:Budgy/EditItemScreen.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  static List<Item> firebaseItems = [];
  static List<Item> sqliteItems = [];
  List<Item> display_list = [];
  bool isLoading = true;
  bool networkError = false;

  @override
  void initState() {
    super.initState();
    display_list.clear();
    fetchDataFromFirebase();
    fetchDataFromSQLite();
  }

  // Fetch data from Firebase
  Future<void> fetchDataFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref('products');

    // Start a timeout timer
    Future.delayed(Duration(seconds: 30), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
          networkError = true;
        });
      }
    });

    try {
      final snapshot = await database.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        List<Item> tempList = [];
        data.forEach((key, category) {
          final categoryName = category['name'] ?? '';
          final items = Map<String, dynamic>.from(category['items']);
          items.forEach((_, itemData) {
            tempList.add(Item.fromMap(Map<String, dynamic>.from(itemData), categoryName));
          });
        });
        setState(() {
          firebaseItems = tempList;
          display_list = List.from(sqliteItems)..addAll(firebaseItems); // SQLite items always on top
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        networkError = true;
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  // Fetch data from SQLite
  Future<void> fetchDataFromSQLite() async {
    try {
      final itemsFromSQLite = await DatabaseService.instance.getAllItems();
      setState(() {
        sqliteItems = itemsFromSQLite;
        display_list = List.from(sqliteItems)..addAll(firebaseItems); // Ensure SQLite items come first
      });
    } catch (e) {
      print("Error fetching data from SQLite: $e");
    }
  }

  // Refresh the data (pull-to-refresh)
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      sqliteItems.clear();
      firebaseItems.clear();
      display_list.clear();
    });
    await fetchDataFromFirebase();
    await fetchDataFromSQLite();
  }

  // Update the display list based on search query
  void updateList(String value) {
    setState(() {
      display_list = sqliteItems.where((element) =>
      element.category_name!.toLowerCase().contains(value.toLowerCase()) ||
          element.item_name!.toLowerCase().contains(value.toLowerCase())
      ).toList()
        ..addAll(firebaseItems.where((element) =>
        element.category_name!.toLowerCase().contains(value.toLowerCase()) ||
            element.item_name!.toLowerCase().contains(value.toLowerCase())
        ));
    });
  }

  // Function to delete SQLite item with confirmation dialog
  void deleteSQLiteItem(int index) async {
    var itemToDelete = sqliteItems[index];

    // Show confirmation dialog
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete ${itemToDelete.item_name}?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false); // User cancels the action
            },
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              Navigator.of(context).pop(true); // User confirms the deletion
            },
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed) {
      try {
        // Call delete function in DatabaseService
        await DatabaseService.instance.deleteItem(itemToDelete);  // Implement delete function in DatabaseService
        setState(() {
          sqliteItems.removeAt(index); // Remove item from local list
          display_list = List.from(sqliteItems)..addAll(firebaseItems); // Update displayed list
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${itemToDelete.item_name} deleted successfully."),
          duration: Duration(seconds: 2),
        ));
      } catch (e) {
        print("Error deleting item: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text("Enter item to search", style: TextStyle(
          color: Colors.teal.shade900,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) => updateList(value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "eg: Canned Sardines",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 20),
              // Check if the app is loading, if network error occurs, or if no items are found
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : networkError
                  ? Center(child: Text("Network Error. Please check your connection.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)))
                  : display_list.isEmpty
                  ? Center(child: Text("No Results Found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
                  : Expanded(
                child: RefreshIndicator(
                    onRefresh: _refreshData,  // Pull-to-refresh callback
                    child: ListView.builder(
                      itemCount: display_list.length,
                      itemBuilder: (context, index) {
                        var item = display_list[index];
                        var item_cost = item.item_cost;

                        // Check if the category name should be displayed
                        bool isFirstItemInCategory = index == 0 || display_list[index - 1].category_name != item.category_name;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display category name as a non-clickable header
                            if (isFirstItemInCategory)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Text(
                                  item.category_name!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade900,
                                  ),
                                ),
                              ),
                            // Display item details
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context, item);  // Return the selected item
                              },
                              child: Card(
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.item_name!} ${item.item_unit}', // Concatenate item name with unit
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      // Display price for SQLite items under the item name
                                      if (sqliteItems.contains(item) && item.item_price != null)
                                        Text(
                                          "₱${item.item_price.toString()}",
                                          style: TextStyle(
                                            color: Colors.teal.shade900,
                                            fontSize: 14, // Smaller font size for price
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                    trailing: sqliteItems.contains(item)
                                        ? PopupMenuButton<String>(
                                      onSelected: (String value) {
                                        if (value == 'delete') {
                                          deleteSQLiteItem(index);
                                        } else if (value == 'edit') {
                                          // Navigate to EditItemScreen when "Edit" is selected
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditItemScreen(item: item), // Pass the selected item
                                            ),
                                          ).then((updatedItem) {
                                            if (updatedItem != null) {
                                              setState(() {
                                                // Update the display list with the edited item
                                                int itemIndex = sqliteItems.indexWhere((i) => i.item_name == updatedItem.item_name); // Use item_name as unique identifier
                                                if (itemIndex != -1) {
                                                  sqliteItems[itemIndex] = updatedItem;
                                                  display_list = List.from(sqliteItems)..addAll(firebaseItems); // Update list with updated SQLite item
                                                }
                                              });
                                            }
                                          });
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    )

                                    : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (item.item_price != null)
                                        Text(
                                          "₱${item.item_price.toString()}",
                                          style: TextStyle(
                                            color: Colors.teal.shade900,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      SizedBox(height: 4),
                                      if (item_cost != null && item_cost != "n/a")
                                        Text(
                                          "Market Price: ₱$item_cost",
                                          style: TextStyle(
                                            color: Colors.teal.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      if (item_cost == null || item_cost == "n/a")
                                        Text(
                                          "Market Price: n/a",
                                          style: TextStyle(
                                            color: Colors.teal.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
