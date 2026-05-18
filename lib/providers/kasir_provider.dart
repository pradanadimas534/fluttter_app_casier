import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';
import '../models/cart_model.dart';

class KasirProvider extends ChangeNotifier {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String formatHarga(double value) {
    return rupiah.format(value);
  }

  String formatStock(ItemModel item) {
    if (item.type == "timbang") {
      return "${item.stock.toStringAsFixed(0)} ${item.unit}";
    }

    return "${item.stock.toStringAsFixed(0)} pcs";
  }

  String getStatus(ItemModel item) {
    if (item.stock <= 0) {
      return "Habis";
    }

    if (item.stock <= getThreshold(item)) {
      return "Menipis";
    }

    return "Aman";
  }

  Color getStatusColor(ItemModel item) {
    if (item.stock <= 0) {
      return Colors.red;
    }

    if (item.stock <= getThreshold(item)) {
      return Colors.orange;
    }

    return Colors.green;
  }

  /// DATA BARANG
  List<ItemModel> items = [
    ItemModel(
      id: 1,
      name: "Aqua",
      price: 3000,
      stock: 50,
      sold: 0,
      type: "satuan",
      unit: "pcs",
    ),

    ItemModel(
      id: 2,
      name: "Indomie",
      price: 3500,
      stock: 30,
      sold: 0,
      type: "satuan",
      unit: "pcs",
    ),
  ];

  /// CART
  List<CartModel> cart = [];

  /// TAMBAH KE CART
  void tambahKeCart(ItemModel item, {double qty = 1}) {
    /// CEK STOCK
    if (item.stock < qty) {
      return;
    }

    /// CEK SUDAH ADA DI CART
    final index = cart.indexWhere((e) => e.id == item.id);

    if (index != -1) {
      cart[index].qty += qty;

      cart[index].total = cart[index].qty * cart[index].price;
    } else {
      cart.add(
        CartModel(
          id: item.id,
          name: item.name,
          type: item.type,
          unit: item.unit,
          price: item.price,
          qty: qty,
          total: item.price * qty,
        ),
      );
    }

    /// KURANGI STOCK
    item.stock -= qty;

    notifyListeners();
  }

  /// KURANGI QTY
  void kurangiQty(int id) {
    final index = cart.indexWhere((e) => e.id == id);

    if (index != -1) {
      cart[index].qty -= cart[index].type == "timbang" ? 0.1 : 1;

      if (cart[index].qty <= 0) {
        cart.removeAt(index);
      }
    }

    notifyListeners();
  }

  String formatQty(double qty) {
    if (qty % 1 == 0) {
      return qty.toInt().toString();
    }

    return qty.toStringAsFixed(2);
  }

  /// TOTAL
  double get total {
    double t = 0;

    for (var item in cart) {
      t += item.total;
    }

    return t;
  }

  /// CLEAR CART
  void clearCart() {
    cart.clear();

    notifyListeners();
  }

  /// TOTAL TRANSAKSI
  int get totalTransaksi {
    return 15;
  }

  /// TOTAL ITEM TERJUAL
  int get totalItemTerjual {
    int total = 0;

    for (var item in items) {
      total += item.sold.toInt();
    }

    return total;
  }

  /// TOTAL PENDAPATAN
  double get totalPendapatan {
    double total = 0;

    for (var item in items) {
      total += item.price * item.sold;
    }

    return total;
  }

  /// BARANG TERLARIS
  List<ItemModel> get barangTerlaris {
    List<ItemModel> sorted = List.from(items);

    sorted.sort((a, b) => b.sold.compareTo(a.sold));

    return sorted.take(5).toList();
  }

  /// NEXT ID
  int nextId = 100;

  /// SET TYPE
  String newItemType = "satuan";

  void setNewType(String type) {
    newItemType = type;

    notifyListeners();
  }

  void addItem({
    required String name,
    required double price,
    required double stock,
    required String type,
    required String unit,
  }) {
    if (name.isEmpty || price <= 0) {
      return;
    }

    items.add(
      ItemModel(
        id: nextId++,

        name: name,

        price: price,

        stock: stock,

        sold: 0,

        type: type,

        unit: unit,
      ),
    );

    notifyListeners();
  }

  void hapusItem(int id) {
    items.removeWhere((e) => e.id == id);

    cart.removeWhere((e) => e.id == id);

    notifyListeners();
  }

  void ubahStok(int id, double value) {
    final item = items.firstWhere((e) => e.id == id);

    item.stock = value < 0 ? 0 : value;

    notifyListeners();
  }

  void ubahHarga(int id, double value) {
    final item = items.firstWhere((e) => e.id == id);

    item.price = value < 0 ? 0 : value;

    notifyListeners();
  }

  double getThreshold(ItemModel item) {
    if (item.type == "timbang") {
      if (item.unit == "gram") {
        return 500;
      }

      if (item.unit == "ons") {
        return 5;
      }

      return 1;
    }

    return 5;
  }
  // String getStatus(ItemModel item) {

  //   if (item.stock <= 0) {
  //     return "Habis";
  //   }

  //   if (item.stock <= getThreshold(item)) {
  //     return "Menipis";
  //   }

  //   return "Aman";
  // }
  // Color getStatusColor(ItemModel item) {

  //   if (item.stock <= 0) {
  //     return Colors.red;
  //   }

  //   if (item.stock <= getThreshold(item)) {
  //     return Colors.orange;
  //   }

  //   return Colors.green;
  // }
  // double getThreshold(ItemModel item) {

  //   if (item.type == "timbang") {

  //     switch (item.unit) {

  //       case "gram":
  //         return 500;

  //       case "ons":
  //         return 5;

  //       case "kg":
  //         return 1;

  //       default:
  //         return 1;
  //     }
  //   }

  //   return 5;
  // }

  int get totalBarang {
    return items.length;
  }

  int get stokMenipis {
    return items.where((e) => e.stock > 0 && e.stock <= getThreshold(e)).length;
  }

  int get stokHabis {
    return items.where((e) => e.stock <= 0).length;
  }

  List<ItemModel> get restockList {
    return items.where((e) => e.stock <= getThreshold(e)).toList();
  }

  String fmtStok(ItemModel item) {
    return "${item.stock} ${item.unit}";
  }
}
