class Item {
  String? category_name;
  String? item_name;
  String? item_unit;
  double? item_price;
  String? item_cost;

  // Named constructor for Firebase mapping
  Item({
    this.category_name,
    this.item_name,
    this.item_unit,
    this.item_price,
    this.item_cost,
  });

  // Factory method to create Item from Firebase data
  factory Item.fromMap(Map<String, dynamic> map, String categoryName) {
    // Normalize the item_cost to a String or null if it's not available
    dynamic rawItemCost = map['MP'];
    String? normalizedCost;
    if (rawItemCost is double) {
      normalizedCost = rawItemCost.toString();
    } else if (rawItemCost is String) {
      normalizedCost = rawItemCost;
    }

    return Item(
      category_name: categoryName, // Pass category name to the object
      item_name: map['name'] ?? '', // Default to empty string if null
      item_unit: map['Unit'] ?? '', // Default to empty string if null
      item_price: (map['SRP'] ?? 0).toDouble(), // Ensure item_price is a double
      item_cost: normalizedCost, // Store normalized item_cost as a String
    );
  }

  // Method to convert SQLite row into Item object
  factory Item.fromSQLite(Map<String, dynamic> row) {
    return Item(
      category_name: "User Input", // Assuming the SQLite table has these columns
      item_name: row['item_name'],
      item_unit: "",
      item_price: row['item_price']?.toDouble(),
    );
  }
}
