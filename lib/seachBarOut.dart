import 'package:Budgy/dummyItems.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Budgy/user_db.dart'; // Update with the correct path
import 'dart:async';

class Seachbarout extends StatefulWidget {
  const Seachbarout({super.key});

  @override
  State<Seachbarout> createState() => _SeachbaroutState();
}

class _SeachbaroutState extends State<Seachbarout> {
  static List<Item> item_list = [];
  List<Item> display_list = List.from(item_list);
  bool isLoading = true;
  String loadingMessage = "Loading data...";
  bool networkError = false;

  String category = ""; // User input category

  void initState() {
    super.initState();
    item_list.clear(); // Clear the item list before fetching new data
    display_list.clear();
    fetchDataFromFirebase();
    fetchDataFromSQLite();
  }

  // Fetch Firebase data
  Future<void> fetchDataFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref('products');

    // Start a timeout timer
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
          final categoryName = categoryData['name'] ?? ''; // Extract category name
          if (category.isEmpty || categoryName.toLowerCase().contains(category.toLowerCase())) {
            final items = Map<String, dynamic>.from(categoryData['items']);
            items.forEach((_, itemData) {
              tempList.add(Item.fromMap(Map<String, dynamic>.from(itemData), categoryName));
            });
          }
        });
        setState(() {
          item_list.addAll(tempList);
          display_list = List.from(item_list);
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

  // Fetch SQLite data
  Future<void> fetchDataFromSQLite() async {
    try {
      // Fetch items from SQLite database
      final itemsFromSQLite = await DatabaseService.instance.getAllItems();

      // No need to map because `getAllItems()` already returns a list of `Item` objects
      setState(() {
        item_list.addAll(itemsFromSQLite);
        display_list = List.from(item_list);
      });
    } catch (e) {
      print("Error fetching data from SQLite: $e");
    }
  }

  // Refresh data on pull-to-refresh
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      item_list.clear(); // Clear the item list before fetching new data
      display_list.clear(); // Clear the display list to avoid duplication
    });
    await fetchDataFromFirebase();
    await fetchDataFromSQLite();
  }

  // Update list based on user input
  void updateCategory(String value) {
    setState(() {
      category = value;
      display_list = item_list.where((element) =>
      (element.category_name != null && element.category_name!.toLowerCase().contains(value.toLowerCase())) ||
          element.item_name!.toLowerCase().contains(value.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter category to search", style: TextStyle(
                color: Colors.teal.shade900,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              )),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) => updateCategory(value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Enter category (e.g. Drinks)",
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
                            onTap: () => (display_list[index]), // Action can be added here
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  '${item.item_name!} ${item.item_unit}', // Concatenate item name with unit
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}