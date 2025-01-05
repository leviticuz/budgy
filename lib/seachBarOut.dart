import 'package:capstonezz/dummyItems.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Seachbarout extends StatefulWidget {
  const Seachbarout({super.key});

  @override
  State<Seachbarout> createState() => _SeachbaroutState();
}

class _SeachbaroutState extends State<Seachbarout> {
  static List<Item> item_list = [];
  List<Item> display_list = List.from(item_list);
  bool isLoading = true;

  void initState(){
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() async {
    final DatabaseReference database = FirebaseDatabase.instance.ref('products');
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
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateList(String value) {
    setState(() {
      display_list = item_list.where((element) =>
      element.category_name!.toLowerCase().contains(value.toLowerCase()) ||
          element.item_name!.toLowerCase().contains(value.toLowerCase())).toList();
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
              Text("Enter item to search", style: TextStyle(
                color: Colors.teal.shade900,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              )),
              SizedBox(height: 20),
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
              Expanded(child: display_list.isEmpty
                  ? Center(child: Text("No Result Found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                itemCount: display_list.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => (display_list[index]),
                  child: Card(
                    child: ListTile(
                      title: Text(display_list[index].item_name!, style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                        "₱${display_list[index].item_price}",
                        style: TextStyle(
                          color: Colors.teal.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
