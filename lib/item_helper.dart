import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_details.dart';

class ItemHelper {
  static Future<void> addItem(String listTitle, String name, double price) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing lists
    String? itemListJson = prefs.getString('itemList');
    if (itemListJson == null) {
      print("Error: No existing lists found!");
      return;
    }

    List<dynamic> itemList = jsonDecode(itemListJson);

    // Find the correct list by title
    for (var list in itemList) {
      if (list['title'] == listTitle) {
        // Add the item to the correct list
        list['items'].add({
          'name': name,
          'price': price,
          'quantity': 1,  // Default quantity
          'isChecked': false
        });

        // Save the updated itemList back to SharedPreferences
        prefs.setString('itemList', jsonEncode(itemList));
        print("✅ Item added successfully to list: $listTitle");
        return;
      }
    }

    print("❌ Error: List with title '$listTitle' not found!");
  }
}
