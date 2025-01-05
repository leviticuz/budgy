import 'package:capstonezz/dummyItems.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {

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

  String selectedItemName = '';
  String selectedItemPrice = '';

  void selectItem(Item selectedItem){
    Navigator.pop(context, selectedItem);
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
              Expanded(child: display_list.isEmpty
                  ? Center(child: Text("No Result Found", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                itemCount: display_list.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => selectItem(display_list[index]),
                  child: Card(
                    child: ListTile(
                      /*tileColor: hoverTap == index
                      ? Colors.teal.shade100
                      : Colors.transparent,*/
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