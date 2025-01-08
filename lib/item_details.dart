class Item {
  String title;
  double budget;
  DateTime date;
  List<ItemDetail> items;

  Item({
    required this.title,
    required this.budget,
    required this.date,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'budget': budget,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'],
      budget: json['budget'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List<dynamic>)
          .map((item) => ItemDetail.fromJson(item))
          .toList(),
    );
  }
}

class ItemDetail {
  String name;
  int quantity;
  bool isChecked;
  double price;

  ItemDetail({
    required this.name,
    required this.quantity,
    required this.isChecked,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'isChecked': isChecked,
      'price': price,
    };
  }

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      name: json['name'],
      quantity: json['quantity'],
      isChecked: json['isChecked'],
      price: json['price'],
    );
  }
}