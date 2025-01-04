class Item {
  String? category_name;
  String? item_name;
  double? item_price;

  Item(this.category_name, this.item_name, this.item_price);

  // Factory method to create Item from Firebase data
  factory Item.fromMap(Map<String, dynamic> map, String categoryName) {
    return Item(
      categoryName, // Pass category name to the object
      map['name'] ?? '',
      (map['SRP'] ?? 0).toDouble(),
    );
  }
}
