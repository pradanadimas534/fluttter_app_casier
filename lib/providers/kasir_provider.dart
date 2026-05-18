import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/cart_model.dart';

class KasirProvider extends ChangeNotifier {

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
  void tambahKeCart(ItemModel item) {

    final index = cart.indexWhere(
      (e) => e.id == item.id,
    );

    if (index != -1) {

      cart[index].qty++;

    } else {

      cart.add(
        CartModel(
          id: item.id,
          name: item.name,
          price: item.price,
          qty: 1,
        ),
      );
    }

    notifyListeners();
  }

  /// KURANGI QTY
  void kurangiQty(int id) {

    final index = cart.indexWhere(
      (e) => e.id == id,
    );

    if (index != -1) {

      cart[index].qty--;

      if (cart[index].qty <= 0) {
        cart.removeAt(index);
      }
    }

    notifyListeners();
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

  List<ItemModel> sorted =
      List.from(items);

  sorted.sort(
    (a, b) => b.sold.compareTo(a.sold),
  );

  return sorted.take(5).toList();
}
}