import 'package:Budgy/dummyItems.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  static List<Item> item_list = [];
  List<Item> display_list = List.from(item_list);
  bool isLoading = true;
  String loadingMessage = "Loading data...";
  bool networkError = false;

  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

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
        data.forEach((key, category) {
          final categoryName = category['name'] ?? ''; // Extract category name
          final items = Map<String, dynamic>.from(category['items']);
          items.forEach((_, itemData) {
            tempList.add(Item.fromMap(Map<String, dynamic>.from(itemData), categoryName));
          });
        });
        setState(() {
          item_list = tempList;
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

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      display_list.clear();
    });
    await fetchDataFromFirebase();
  }

  void updateList(String value) {
    setState(() {
      display_list = item_list.where((element) =>
      element.category_name!.toLowerCase().contains(value.toLowerCase()) ||
          element.item_name!.toLowerCase().contains(value.toLowerCase())
      ).toList();
    });
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
                          // Display item details and make the item clickable
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context, item);  // Return the selected item
                            },
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
