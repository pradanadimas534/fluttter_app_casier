import 'package:flutter/material.dart';
import '../screens/tambah_produk_page.dart';

class TambahButton extends StatelessWidget {

  final Function() onSuccess;

  const TambahButton({
    super.key,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TambahProdukPage(),
          ),
        );

        // kalau berhasil tambah → refresh
        if (result == true) {
          onSuccess();
        }

      },
    );

  }

}