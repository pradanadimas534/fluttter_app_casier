import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kasir_provider.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<KasirProvider>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Riwayat & Statistik",
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// TITLE
            const Text(
              "Ringkasan",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// SUMMARY GRID
            Row(
              children: [

                Expanded(
                  child: summaryCard(
                    "Total Transaksi",
                    "${provider.totalTransaksi}",
                    Icons.receipt_long,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: summaryCard(
                    "Item Terjual",
                    "${provider.totalItemTerjual}",
                    Icons.shopping_bag,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: summaryCard(
                    "Pendapatan",
                    "Rp ${provider.totalPendapatan.toStringAsFixed(0)}",
                    Icons.payments,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// TERLARIS
            const Text(
              "Barang Terlaris",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            provider.barangTerlaris.isEmpty

                ? const Center(
                    child: Text(
                      "Belum ada data",
                    ),
                  )

                : Column(

                    children:
                        provider.barangTerlaris.map((item) {

                      return Card(

                        child: ListTile(

                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.orange.shade100,

                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),

                          title: Text(
                            item.name,
                          ),

                          subtitle: Text(
                            "Terjual : ${item.sold}",
                          ),

                          trailing: Text(
                            "Rp ${(item.price * item.sold).toStringAsFixed(0)}",

                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 30),

            /// RIWAYAT TRANSAKSI
            const Text(
              "Riwayat Transaksi",

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ListView.builder(

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount: 10,

              itemBuilder: (context, index) {

                return Card(

                  child: ListTile(

                    leading: CircleAvatar(
                      child: Text(
                        "${index + 1}",
                      ),
                    ),

                    title: Text(
                      "Transaksi #${index + 1}",
                    ),

                    subtitle: const Text(
                      "3 Barang",
                    ),

                    trailing: const Text(
                      "Rp 50.000",

                      style: TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard(
    String title,
    String value,
    IconData icon,
  ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: Colors.green,
          ),

          const SizedBox(height: 12),

          Text(
            title,

            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}