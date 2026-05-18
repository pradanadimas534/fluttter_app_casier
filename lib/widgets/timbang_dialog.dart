import 'package:flutter/material.dart';

import '../providers/kasir_provider.dart';

class TimbangDialog extends StatefulWidget {

  final dynamic item;

  final KasirProvider provider;

  const TimbangDialog({

    super.key,

    required this.item,

    required this.provider,
  });

  @override
  State<TimbangDialog> createState() =>
      _TimbangDialogState();
}

class _TimbangDialogState
    extends State<TimbangDialog> {

  final timbangController =
      TextEditingController();

  double totalHarga = 0;

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),

      title: Row(

        children: [

          const Icon(
            Icons.scale,
            color: Colors.orange,
          ),

          const SizedBox(width: 10),

          Expanded(

            child: Text(
              widget.item.name,
            ),
          ),
        ],
      ),

      content: SizedBox(

        width: 350,

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            /// HARGA
            Container(

              padding:
                  const EdgeInsets.all(14),

              decoration: BoxDecoration(

                color:
                    Colors.green.shade50,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: Column(

                children: [

                  const Text(
                    "Harga",
                  ),

                  const SizedBox(height: 6),

                  Text(

                    widget.provider
                        .formatHarga(
                      widget.item.price,
                    ),

                    style:
                        const TextStyle(

                      fontSize: 24,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INPUT
            TextField(

              controller:
                  timbangController,

              keyboardType:
                  TextInputType.number,

              autofocus: true,

              decoration:
                  InputDecoration(

                labelText:
                    "Jumlah (${widget.item.unit})",

                hintText:
                    "Masukkan jumlah",

                filled: true,

                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),

              onChanged: (v) {

                double qty =
                    double.tryParse(v) ??
                        0;

                setState(() {

                  totalHarga =
                      qty *
                          widget.item.price;
                });
              },
            ),

            const SizedBox(height: 20),

            /// TOTAL
            Container(

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color:
                    Colors.orange.shade50,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Column(

                children: [

                  const Text(
                    "Total Harga",
                  ),

                  const SizedBox(height: 8),

                  Text(

                    widget.provider
                        .formatHarga(
                      totalHarga,
                    ),

                    style:
                        const TextStyle(

                      fontSize: 28,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PRESET
            Wrap(

              spacing: 10,
              runSpacing: 10,

              children: [

                presetButton(0.25),
                presetButton(0.5),
                presetButton(1),
                presetButton(2),
              ],
            ),
          ],
        ),
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);
          },

          child: const Text(
            "Batal",
          ),
        ),

        ElevatedButton.icon(

          style:
              ElevatedButton.styleFrom(

            backgroundColor:
                Colors.green,

            foregroundColor:
                Colors.white,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
          ),

          onPressed: () {

            double qty =
                double.tryParse(
                      timbangController
                          .text,
                    ) ??
                    0;

            if (qty <= 0) return;

            widget.provider
                .tambahKeCart(
              widget.item,
              qty: qty,
            );

            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.add_shopping_cart,
          ),

          label: const Text(
            "Tambah",
          ),
        ),
      ],
    );
  }

  /// PRESET BUTTON
  Widget presetButton(double qty) {

    return InkWell(

      borderRadius:
          BorderRadius.circular(14),

      onTap: () {

        timbangController.text =
            qty.toString();

        setState(() {

          totalHarga =
              qty *
                  widget.item.price;
        });
      },

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color:
              Colors.orange.shade50,

          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),

        child: Text(

          "$qty ${widget.item.unit}",

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}