import 'package:flutter/material.dart';
import '../service/apiService.dart';
import '../models/produk.dart';
import 'tambah_produk_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  List<Produk> produk = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    setState(() => loading = true);

    final data = await ApiService.getProduk();

    setState(() {
      produk = data.map((e) => Produk.fromJson(e)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda Kasir"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahProdukPage()),
              );

              if (result == true) {
                fetchProduk(); // reload data
              }
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: produk.length,
              itemBuilder: (context, index) {
                final item = produk[index];

                return ListTile(
                  title: Text(item.nama),
                  subtitle: Text("Rp ${item.harga} | Stok: ${item.stok}"),
                );
              },
            ),
    );
  }
}
