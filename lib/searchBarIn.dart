import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:Budgy/user_db.dart';
import 'dummyItems.dart';
import 'item_helper.dart';
import 'add_item.dart';
import 'package:Budgy/EditItemScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Searchbar extends StatefulWidget {
  final String listTitle;

  const Searchbar({required this.listTitle, Key? key}) : super(key: key);

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
      remainingBudget = remainingBudget - (itemPrice * quantity); // Calculate remaining balance
    });
  }

  // Fetch data from Firebase
  Future<void> fetchDataFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref('products');

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

          tempCategories.add(Category(name: categoryName, items: categoryItems));
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
        builder: (context) => CategoryItemsPage(
          category: category,
          listTitle: widget.listTitle,
          updateRemainingBalance: updateRemainingBalance,  // Pass the callback here
        ),
      ),
    );
  }


  // Show modal to add item with quantity
  void _showAddItemModal(Item item) {
    TextEditingController quantityController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.item_name ?? 'Unknown Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Price: ₱${item.item_price ?? 0.0}"),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the modal
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                double price = item.item_price ?? 0.0;
                String name = item.item_name ?? "Unknown Item";
                int quantity = int.tryParse(quantityController.text) ?? 1;

                // Call addItem to add item to the list
                await ItemHelper.addItem(widget.listTitle, name, price, quantity);

                // Update remaining budget after adding the item
                updateRemainingBalance(price, quantity);

                // Reset the search bar and item list
                setState(() {
                  searchQuery = '';
                  filterItems();  // Reset displayed items
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name added to the list!')),
                );
                Navigator.of(context).pop();  // Close the modal
              },
              child: Text("Add"),
            ),
          ],
        );
      },
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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.teal.shade900), // "+" icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute (
                  builder: (context) => AddItemScreen(
                    onAddItem: (name, price, quantity) async {
                      // Handle added item (optional)
                      await ItemHelper.addItem(widget.listTitle, name, price, quantity);
                      print("Added Item: $name, $price, $quantity");
                      updateRemainingBalance(price, quantity);
                    },
                    budget: remainingBudget, // Example budget, replace with your actual budget
                    currentTotalCost: totalSpent, // Replace with actual current total cost
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFB1E8DE),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining Budget:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₱${remainingBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Colors.teal.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
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
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 8,
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
                          child: category.name!.contains(" ")
                              ? Text(
                            category.name!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.teal.shade900,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                              : FittedBox(
                            fit: BoxFit.scaleDown,
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
                        _showAddItemModal(item);  // Show the modal when item is tapped
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "₱${item.item_price?.toStringAsFixed(2) ?? '0.00'}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade900,
                                ),
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
  String? name;
  List<Item>? items;

  Category({this.name, this.items});
}

class CategoryItemsPage extends StatelessWidget {
  final Category category;
  final String listTitle;
  final Function(double, int) updateRemainingBalance; // Callback function

  CategoryItemsPage({
    required this.category,
    required this.listTitle,
    required this.updateRemainingBalance,  // Accept the callback
  });

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
          itemCount: category.items?.length ?? 0, // Null check for items length
          itemBuilder: (context, index) {
            var item = category.items![index]; // Safely access item because itemCount is checked

            return GestureDetector(
              onTap: () {
                double price = 0.0;

                // First, check if item.item_cost is neither null nor "n/a"
                if (item.item_cost != null && item.item_cost != "n/a") {
                  // Safely parse item.item_cost to double
                  price = double.tryParse(item.item_cost!) ?? 0.0; // Use '!' to assert it's not null
                } else {
                  price = item.item_price ?? 0.0;
                }
                String name = item.item_name ?? "Unknown Item";

                // Show modal for entering quantity
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    int quantity = 1; // Default quantity

                    return AlertDialog(
                      title: Text("Add Item"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Name: $name"),
                          Text("Price: ₱$price"),
                          TextField(
                            decoration: InputDecoration(labelText: "Quantity"),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              quantity = int.tryParse(value) ?? 1; // Default to 1 if invalid
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the modal
                          },
                        ),
                        TextButton(
                          child: Text("Add"),
                          onPressed: () async{
                            await ItemHelper.addItem(listTitle, name, price, quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$name added to the list!')),
                            );
                            Navigator.of(context).pop();
                            // Call updateRemainingBalance to adjust the budget
                            updateRemainingBalance(price, quantity);
                          },
                        ),
                      ],
                    );
                  },
                );
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


