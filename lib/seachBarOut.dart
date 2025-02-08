import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:Budgy/user_db.dart';
import 'dummyItems.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Seachbarout extends StatefulWidget {
  final String listTitle;

  const Seachbarout({required this.listTitle, Key? key}) : super(key: key);

  @override
  State<Seachbarout> createState() => _SeachbaroutState();
}

class _SeachbaroutState extends State<Seachbarout> {
  static List<Item> firebaseItems = [];
  static List<Item> sqliteItems = [];
  List<Item> displayedItems = [];
  List<Category> categories = [];
  bool isLoading = true;
  bool networkError = false;
  String searchQuery = '';
  double remainingBudget = 0.0;
  double totalSpent = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
    fetchDataFromSQLite();
    _getBudgetFromSharedPreferences();
  }

  void _getBudgetFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemListJson = prefs.getString('itemList');

    if (itemListJson != null) {
      List<dynamic> itemList = jsonDecode(itemListJson);
      var selectedList = itemList.firstWhere(
            (list) => list['title'] == widget.listTitle,
        orElse: () => null,
      );

      if (selectedList != null) {
        double budget = selectedList['budget'] ?? 0.0;
        List<dynamic> items = selectedList['items'] ?? [];

        // Calculate total spent
        totalSpent = items.fold(0.0, (sum, item) {
          return sum + (item['price'] * item['quantity']);
        });

        setState(() {
          remainingBudget = budget - totalSpent; // Remaining balance
        });
      }
    }
  }

  // Function to update the remaining balance after adding an item
  void updateRemainingBalance(double itemPrice, int quantity) {
    setState(() {
      totalSpent += itemPrice * quantity;
      remainingBudget = remainingBudget -
          (itemPrice * quantity); // Calculate remaining balance
    });
  }

  // Fetch data from Firebase
  Future<void> fetchDataFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref(
        'products');

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
        List<Item> tempItems = [];
        List<Category> tempCategories = [];

        data.forEach((key, category) {
          final categoryName = category['name'] ?? '';
          final items = Map<String, dynamic>.from(category['items']);
          List<Item> categoryItems = [];

          items.forEach((_, itemData) {
            Item item = Item.fromMap(
                Map<String, dynamic>.from(itemData), categoryName);
            tempItems.add(item);
            categoryItems.add(item);
          });

          tempCategories.add(
              Category(name: categoryName, items: categoryItems));
        });

        setState(() {
          firebaseItems = tempItems;
          categories = tempCategories;
          displayedItems = firebaseItems + sqliteItems;
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

  Future<void> fetchDataFromSQLite() async {
    try {
      final itemsFromSQLite = await DatabaseService.instance.getAllItems();
      setState(() {
        sqliteItems = itemsFromSQLite;
        displayedItems = firebaseItems + sqliteItems;
      });
    } catch (e) {
      print("Error fetching data from SQLite: $e");
    }
  }

  void updateSearchQuery(String value) {
    setState(() {
      searchQuery = value;
      filterItems();
    });
  }

  void filterItems() {
    if (searchQuery.isNotEmpty) {
      setState(() {
        displayedItems = (firebaseItems + sqliteItems).where((item) {
          return item.item_name!.toLowerCase().startsWith(searchQuery.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        displayedItems = firebaseItems + sqliteItems;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text(
          "Search Items",
          style: TextStyle(
            color: Colors.teal.shade900,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "Search Item",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
            searchQuery.isEmpty
                ? Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryItemsPage(category: category, listTitle: '',),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            category.name!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                : Expanded(
              child: displayedItems.isEmpty
                  ? Center(child: Text("No items available"))
                  : ListView.builder(
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  var item = displayedItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(
                        item.item_name!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Text(
                        "₱${item.item_price?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  class Category {
  String? name;
  List<Item>? items;

  Category({this.name, this.items});
}

class CategoryItemsPage extends StatelessWidget {
  final Category category;
  final String listTitle;

  CategoryItemsPage({required this.category, required this.listTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB1E8DE),
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text(category.name!),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: category.items?.length ?? 0,
          itemBuilder: (context, index) {
            var item = category.items![index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.item_name!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      "₱${item.item_price?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(
                        color: Colors.teal.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
