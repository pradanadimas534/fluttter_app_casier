import 'package:flutter/material.dart';

class TimbangDialog extends StatefulWidget {
  const TimbangDialog({super.key});

  @override
  State<TimbangDialog> createState() => _TimbangDialogState();
}

class _TimbangDialogState extends State<TimbangDialog> {

  final TextEditingController controller =
      TextEditingController();

  double total = 0;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text("Timbang Barang"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: controller,
            keyboardType: TextInputType.number,

            decoration: const InputDecoration(
              labelText: "Jumlah",
            ),

            onChanged: (v) {
              setState(() {
                total = (double.tryParse(v) ?? 0) * 1300;
              });
            },
          ),

          const SizedBox(height: 20),

          Text(
            "Total : Rp ${total.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Batal"),
        ),

        ElevatedButton(
          onPressed: () {},
          child: const Text("Tambah"),
        ),
      ],
    );
  }
}