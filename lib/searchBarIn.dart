import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:Budgy/user_db.dart';
import 'dummyItems.dart';
import 'package:Budgy/EditItemScreen.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  static List<Item> firebaseItems = [];
  static List<Item> sqliteItems = [];
  List<Item> displayedItems = [];
  List<Category> categories = [];
  bool isLoading = true;
  bool networkError = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
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
        List<Item> tempItems = [];
        List<Category> tempCategories = [];

        data.forEach((key, category) {
          final categoryName = category['name'] ?? '';
          final items = Map<String, dynamic>.from(category['items']);
          List<Item> categoryItems = [];

          items.forEach((_, itemData) {
            Item item = Item.fromMap(Map<String, dynamic>.from(itemData), categoryName);
            tempItems.add(item);
            categoryItems.add(item);
          });

          // Add category with its items
          tempCategories.add(Category(name: categoryName, items: categoryItems));
        });

        setState(() {
          firebaseItems = tempItems;
          categories = tempCategories;
          displayedItems = firebaseItems + sqliteItems; // Combine Firebase and SQLite items
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
        displayedItems = firebaseItems + sqliteItems; // Combine Firebase and SQLite items
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
        displayedItems = displayedItems.where((item) {
          return item.item_name!.toLowerCase().startsWith(searchQuery.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        displayedItems = firebaseItems + sqliteItems;
      });
    }
  }

  void showItemsUnderCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryItemsPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB1E8DE),
        title: Text("Search Items", style: TextStyle(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : networkError
                  ? Center(child: Text("Network Error. Please check your connection.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)))
                  : searchQuery.isEmpty
                  ? Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // items per row
                    crossAxisSpacing: 4, // Space horizontally
                    mainAxisSpacing: 8, // Space vertically
                    childAspectRatio: 1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    var category = categories[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          showItemsUnderCategory(category);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: category.name!.contains(" ") // Check if multi-word
                              ? Text(
                            category.name!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.teal.shade900,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3, // Wrap multi-word text
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                              : FittedBox(
                            fit: BoxFit.scaleDown, // Shrink long words
                            child: Text(
                              category.name!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.teal.shade900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : SizedBox.shrink(),
              searchQuery.isNotEmpty
                  ? Expanded(
                child: displayedItems.isEmpty
                    ? Center(child: Text("No items available", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
                    : ListView.builder(
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    var item = displayedItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.item_name!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              if (item.item_price != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₱${item.item_price}",
                                      style: TextStyle(
                                        color: Colors.teal.shade900,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.item_cost != null && item.item_cost != "n/a")
                                      Text(
                                        "Market Price: ₱${item.item_cost}",
                                        style: TextStyle(
                                          color: Colors.teal.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    if (item.item_cost == null || item.item_cost == "n/a")
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class Category {
  final String? name;
  final List<Item> items;

  Category({this.name, required this.items});
}

class CategoryItemsPage extends StatelessWidget {
  final Category category;

  CategoryItemsPage({required this.category});

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
          itemCount: category.items.length,
          itemBuilder: (context, index) {
            var item = category.items[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, item);
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.item_name!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: null,
                        ),
                      ),
                      if (item.item_price != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₱${item.item_price}",
                              style: TextStyle(
                                color: Colors.teal.shade900,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.item_cost != null && item.item_cost != "n/a")
                              Text(
                                "Market Price: ₱${item.item_cost}",
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            if (item.item_cost == null || item.item_cost == "n/a")
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


