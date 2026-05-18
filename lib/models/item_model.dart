class ItemModel {
  int id;
  String name;
  double price;
  double stock;
  double sold;
  String type;
  String unit;

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.sold,
    required this.type,
    required this.unit,
  });
}