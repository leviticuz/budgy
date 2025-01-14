import 'package:Budgy/dummyItems.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Budgy/user_db.dart'; // Update with the correct path
import 'dart:async';
import 'homePage.dart';

class Seachbarout extends StatefulWidget {
  const Seachbarout({super.key});

  @override
  State<Seachbarout> createState() => _SeachbaroutState();
}

class _SeachbaroutState extends State<Seachbarout> {
  static List<Item> firebaseItems = []; // For Firebase items
  static List<Item> sqliteItems = [];   // For SQLite items
  List<Item> display_list = [];         // To show the combined list (if needed)
  String loadingMessage = "Loading data...";
  bool isLoading = true;
  bool networkError = false;

  String category = ""; // User input category

  @override
  void initState() {
    super.initState();
    display_list.clear();
    fetchDataFromSQLite();
    fetchDataFromFirebase();
  }

  // Fetch Firebase data (Unchanged)
  Future<void> fetchDataFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref('products');

    Future.delayed(Duration(seconds: 30), () {
      if (isLoading) {
        setState(() {
          loadingMessage = "Network Unstable. Please try again.";
        });
      }
    });

    try {
      final snapshot = await database.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        List<Item> tempList = [];
        data.forEach((key, categoryData) {
          final categoryName = categoryData['name'] ?? '';
          if (category.isEmpty || categoryName.toLowerCase().contains(category.toLowerCase())) {
            final items = Map<String, dynamic>.from(categoryData['items']);
            items.forEach((_, itemData) {
              tempList.add(Item.fromMap(Map<String, dynamic>.from(itemData), categoryName));
            });
          }
        });
        setState(() {
          firebaseItems = tempList;
          display_list = List.from(sqliteItems)..addAll(firebaseItems);
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

  // Fetch SQLite data (Separate from Firebase)
  Future<void> fetchDataFromSQLite() async {
    try {
      final itemsFromSQLite = await DatabaseService.instance.getAllItems();
      setState(() {
        sqliteItems = itemsFromSQLite;
        // Ensure SQLite items always come first in the display_list
        display_list = List.from(sqliteItems)..addAll(firebaseItems);
      });
    } catch (e) {
      print("Error fetching data from SQLite: $e");
    }
  }

  // Keyword-based category mapping
  Map<String, String> keywordToCategory = {
    "kape": "coffee products",
    "tubig": "water",
    "sabon": "soap",
    "asin": "salt",
    "suka": "vinegar",
    "tinapay": "bread",
    "kandila": "candles",
    "gatas": "milk",
    "toyo": "soy sauce",
  };

  // Update list based on user input
  void updateCategory(String value) {
    setState(() {
      category = value;

      // Check for matching keywords
      String? matchedCategory = keywordToCategory.entries
          .firstWhere((entry) => entry.key.toLowerCase() == value.toLowerCase(), orElse: () => const MapEntry("", ""))
          .value;

      // If a keyword matches, filter by its associated category
      if (matchedCategory.isNotEmpty) {
        display_list = firebaseItems.where((element) =>
        element.category_name != null &&
            element.category_name!.toLowerCase().contains(matchedCategory.toLowerCase())).toList()
          ..addAll(sqliteItems.where((element) =>
          element.category_name != null &&
              element.category_name!.toLowerCase().contains(matchedCategory.toLowerCase())));
      } else {
        // Default category filtering
        display_list = firebaseItems.where((element) =>
        element.category_name != null &&
            element.category_name!.toLowerCase().contains(value.toLowerCase())).toList()
          ..addAll(sqliteItems.where((element) =>
          element.category_name != null &&
              element.category_name!.toLowerCase().contains(value.toLowerCase())));
      }
    });
  }

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
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Color(0xFF5BB7A6),
              automaticallyImplyLeading: false,
              title: Text(
                "Enter category to search",
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              onChanged: (value) => updateCategory(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "Enter category (e.g. Drinks or keywords)",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : networkError
                ? Center(
              child: Text(
                "Network Error. Please check your connection.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            )
                : display_list.isEmpty
                ? Center(
                child: Text("No Results Found",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)))
                : Expanded(
              child: RefreshIndicator(
                  onRefresh: () async {
                    await fetchDataFromFirebase();
                    await fetchDataFromSQLite();
                  },
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
                          GestureDetector(
                            onTap: () {
                              // Add your action for the item tap (if needed)
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
                                    }
                                  },
                                  itemBuilder: (context) => [
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
                                    Text(
                                      item_cost == null || item_cost == "n/a"
                                          ? "Market Price: n/a"
                                          : "Market Price: ₱$item_cost",
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
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
