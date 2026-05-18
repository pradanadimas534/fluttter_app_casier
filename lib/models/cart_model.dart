class CartModel {

  int id;
  String name;
  double price;
  int qty;

  CartModel({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
  });

  double get total => price * qty;
}