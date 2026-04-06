import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl =
      "https://script.google.com/macros/s/AKfycbyImUPMEdK6kfsuY_mb2lvtb5UJUiHV9uPqo4IxYL3gClzAEm7BJXUXKa9yahly8yDO/exec";
  static Future<List> getProduk() async {
    final res = await http.get(Uri.parse("$baseUrl?action=produk"));

    return jsonDecode(res.body);
  }

  static Future tambahTransaksi(String produk, int qty, int total) async {
    await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode({
        "action": "tambahTransaksi",
        "id": DateTime.now().toString(),
        "produk": produk,
        "qty": qty,
        "total": total,
      }),
    );
  }

  static Future tambahProduk(String nama, int harga, int stok) async {
    await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode({
        "action": "tambahProduk",
        "nama": nama,
        "harga": harga,
        "stok": stok,
      }),
    );
  }
}
