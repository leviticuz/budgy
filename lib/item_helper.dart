import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ItemHelper {
  static Future<void> addItem(String listTitle, String name, double price, int quantity) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? itemListJson = prefs.getString('itemList');
    if (itemListJson == null) {
      print("Error: No existing lists found!");
      return;
    }

    List<dynamic> itemList = jsonDecode(itemListJson);

    for (var list in itemList) {
      if (list['title'] == listTitle) {
        List<dynamic> items = list['items'];

        var existingItem = items.firstWhere(
              (item) => item['name'] == name,
          orElse: () => {},
        );

        if (existingItem.isNotEmpty) {
          existingItem['quantity'] += quantity; // Increase quantity
        } else {
          items.add({
            'name': name,
            'price': price,
            'quantity': quantity,  // Use input quantity
            'isChecked': false
          });
        }

        prefs.setString('itemList', jsonEncode(itemList));
        print("✅ Item added/updated successfully in list: $listTitle");
        return;
      }
    }

    print("❌ Error: List with title '$listTitle' not found!");
  }

}
