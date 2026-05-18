class CartModel {
  int id;
  String name;
  String type;
  String unit;
  double price;
  double qty;
  double total;

  CartModel({
    required this.id,
    required this.name,
    required this.type,
    required this.unit,
    required this.price,
    required this.qty,
    required this.total,
  });
}
