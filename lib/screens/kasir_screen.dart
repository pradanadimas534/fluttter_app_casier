import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kasir_provider.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {

  final bayarController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<KasirProvider>(context);

    double bayar =
        double.tryParse(bayarController.text) ?? 0;

    double kembalian =
        bayar - provider.total;

    return Scaffold(

      appBar: AppBar(
        title: const Text("KasirKu"),
      ),

      body: Row(
        children: [

          /// KIRI = BARANG
          Expanded(
            flex: 2,

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: GridView.builder(

                itemCount: provider.items.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),

                itemBuilder: (context, index) {

                  final item =
                      provider.items[index];

                  return InkWell(

                    onTap: () {
                      provider.tambahKeCart(item);
                    },

                    child: Card(

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              item.name,

                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const Spacer(),

                            Text(
                              "Rp ${item.price.toStringAsFixed(0)}",

                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Stok : ${item.stock}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// KANAN = CART
          Container(
            width: 350,
            color: Colors.white,

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Keranjang Belanja",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LIST CART
                  Expanded(

                    child: provider.cart.isEmpty

                        ? const Center(
                            child: Text(
                              "Keranjang kosong",
                            ),
                          )

                        : ListView.builder(

                            itemCount:
                                provider.cart.length,

                            itemBuilder:
                                (context, index) {

                              final cart =
                                  provider.cart[index];

                              return Card(

                                child: ListTile(

                                  title: Text(
                                    cart.name,
                                  ),

                                  subtitle: Text(
                                    "${cart.qty} x Rp ${cart.price.toStringAsFixed(0)}",
                                  ),

                                  trailing: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,

                                    children: [

                                      IconButton(
                                        onPressed: () {
                                          provider.kurangiQty(
                                            cart.id,
                                          );
                                        },

                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                      ),

                                      Text(
                                        "${cart.total.toStringAsFixed(0)}",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const Divider(),

                  /// SUBTOTAL
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      const Text("Subtotal"),

                      Text(
                        "Rp ${provider.total.toStringAsFixed(0)}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// TOTAL
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      const Text(
                        "Total Bayar",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      Text(
                        "Rp ${provider.total.toStringAsFixed(0)}",

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// INPUT BAYAR
                  TextField(
                    controller: bayarController,

                    keyboardType:
                        TextInputType.number,

                    decoration: InputDecoration(

                      hintText: "Uang diterima",

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      suffixIcon: IconButton(

                        onPressed: () {

                          bayarController.text =
                              provider.total.toString();

                          setState(() {});
                        },

                        icon: const Icon(
                          Icons.payments,
                        ),
                      ),
                    ),

                    onChanged: (v) {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 15),

                  /// KEMBALIAN
                  Container(

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          "Kembalian",
                        ),

                        Text(

                          "Rp ${kembalian < 0 ? 0 : kembalian.toStringAsFixed(0)}",

                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON BAYAR
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.all(16),
                      ),

                      onPressed:

                          provider.cart.isEmpty ||
                                  bayar <
                                      provider.total

                              ? null

                              : () {

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(

                                    const SnackBar(
                                      content: Text(
                                        "Pembayaran berhasil",
                                      ),
                                    ),
                                  );

                                  provider.clearCart();

                                  bayarController.clear();

                                  setState(() {});
                                },

                      child: const Text(
                        "Proses Pembayaran",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}