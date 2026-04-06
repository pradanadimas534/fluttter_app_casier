import 'package:flutter/material.dart';
import '../service/apiService.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),

            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga"),
            ),

            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stok"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await ApiService.tambahProduk(
                  namaController.text,
                  int.parse(hargaController.text),
                  int.parse(stokController.text),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produk berhasil disimpan")),
                );

               Navigator.pop(context, true);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
