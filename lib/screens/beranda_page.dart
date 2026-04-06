import 'package:flutter/material.dart';
import '../models/produk.dart';
import '../service/apiService.dart';
import '../widgets/tambah_produk_widget.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<Produk> produk = [];
  bool loading = true;

  // 🛒 keranjang (id produk : qty)
  Map<String, int> cart = {};

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  // 🔹 ambil data dari API
  Future<void> fetchProduk() async {
    try {
      final data = await ApiService.getProduk();

      setState(() {
        produk = data.map((e) => Produk.fromJson(e)).toList();
        loading = false;
      });
    } catch (e) {
      loading = false;
      debugPrint("ERROR: $e");
    }
  }

  // ➕ tambah jumlah
  void tambahQty(String id) {
    setState(() {
      cart[id] = (cart[id] ?? 0) + 1;
    });
  }

  // ➖ kurangi jumlah
  void kurangQty(String id) {
    setState(() {
      if ((cart[id] ?? 0) > 0) {
        cart[id] = cart[id]! - 1;
      }
    });
  }

  // 💰 hitung total semua
  int getTotal() {
    int total = 0;

    for (var item in produk) {
      int qty = cart[item.id] ?? 0;
      total += item.harga * qty;
    }

    return total;
  }

  // 💳 checkout
  void checkout() {
    if (getTotal() == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Belum ada item")));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Transaksi berhasil")));

    // reset keranjang
    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir"),
        centerTitle: true,
        actions: [
          TambahButton(
            onSuccess: () {
              fetchProduk(); // refresh data
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : produk.isEmpty
          ? const Center(child: Text("Data kosong"))
          : ListView.builder(
              itemCount: produk.length,
              itemBuilder: (context, index) {
                final item = produk[index];
                int qty = cart[item.id] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📦 nama produk
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 💰 harga
                        Text("Rp ${item.harga}"),

                        const SizedBox(height: 8),

                        // ➕ ➖ CONTROL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ➖
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: qty > 0
                                  ? () => kurangQty(item.id)
                                  : null,
                            ),

                            // jumlah
                            Text("$qty", style: const TextStyle(fontSize: 16)),

                            // ➕
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => tambahQty(item.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      // 🔥 TOTAL + CHECKOUT
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 18)),

                Text(
                  "Rp ${getTotal()}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // tombol bayar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: checkout,
                child: const Text("Checkout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
