class Item {
  String? category_name;
  String? item_name;
  String? item_unit;
  double? item_price;
  dynamic item_cost;

  Item(this.category_name, this.item_name, this.item_unit, this.item_price, this.item_cost);

  // Factory method to create Item from Firebase data
  factory Item.fromMap(Map<String, dynamic> map, String categoryName) {
    dynamic rawItemCost = map['MP'];

    // Normalize item_cost to a String, regardless of its type
    String? normalizedCost;
    if (rawItemCost is double) {
      normalizedCost = rawItemCost.toString();
    } else if (rawItemCost is String) {
      normalizedCost = rawItemCost;
    }

    return Item(
      categoryName, // Pass category name to the object
      map['name'] ?? '',
      map['Unit'] ?? '',
      (map['SRP'] ?? 0).toDouble(), // Ensure item_price is a double
      normalizedCost, // Store normalized item_cost as a String
    );
  }
}
