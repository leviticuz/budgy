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
}
