import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kasir_provider.dart';
import '../widgets/cart_panel.dart';
import '../widgets/timbang_dialog.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  final bayarController = TextEditingController();

  String search = "";

  String selectedFilter = "all";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KasirProvider>(context);

    /// FILTER
    final filteredItems = provider.items.where((item) {
      final matchSearch = item.name.toLowerCase().contains(
        search.toLowerCase(),
      );

      final matchFilter =
          selectedFilter == "all" ||
          item.type == selectedFilter;

      return matchSearch && matchFilter;
    }).toList();

    double bayar =
        double.tryParse(bayarController.text) ?? 0;

    double kembalian =
        bayar - provider.total;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          "KasirKu",

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
// ... potongan kode atas KasirScreen tetap sama ...

      body: LayoutBuilder(
        builder: (context, constraints) {

          /// =====================================
          /// MOBILE
          /// =====================================
          if (constraints.maxWidth < 900) {
            return Column(
              children: [

                /// PANEL BARANG
                Expanded(
                  flex: 11, // Memberikan proporsi lebih besar untuk panel barang
                  child: buildLeftPanel(
                    provider,
                    filteredItems,
                  ),
                ),

                const Divider(height: 1, thickness: 1), // Pembatas tipis

                /// CART PANEL BAWAH (Diubah dari SizedBox tinggi statis ke Flexible/Expanded)
                Expanded(
                  flex: 10, // Memberikan ruang yang cukup dan elastis untuk keranjang + pembayaran
                  child: CartPanel(
                    provider: provider,
                    bayarController: bayarController,
                    bayar: bayar,
                    kembalian: kembalian,
                    onChanged: () {
                      setState(() {});
                    },
                    onBayar: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pembayaran berhasil ✓"),
                        ),
                      );
                      provider.clearCart();
                      bayarController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ],
            );
          }

          /// =====================================
          /// DESKTOP
          /// =====================================
// ... sisa kode desktop ke bawah tetap sama ...
          return Row(
            children: [

              /// LEFT
              Expanded(
                flex: 2,

                child: buildLeftPanel(
                  provider,
                  filteredItems,
                ),
              ),

              /// RIGHT
              SizedBox(
                width: 400,

                child: CartPanel(
                  provider: provider,

                  bayarController:
                      bayarController,

                  bayar: bayar,

                  kembalian:
                      kembalian,

                  onChanged: () {
                    setState(() {});
                  },

                  onBayar: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Pembayaran berhasil ✓",
                        ),
                      ),
                    );

                    provider.clearCart();

                    bayarController.clear();

                    setState(() {});
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// =====================================
  /// LEFT PANEL
  /// =====================================
  Widget buildLeftPanel(
    KasirProvider provider,
    List filteredItems,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [

          /// SEARCH
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: TextField(
              decoration:
                  const InputDecoration(
                    hintText:
                        "Cari barang...",

                    border:
                        InputBorder.none,

                    icon: Icon(
                      Icons.search,
                    ),
                  ),

              onChanged: (v) {
                setState(() {
                  search = v;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          /// FILTER
          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,

            child: Row(
              children: [
                filterButton(
                  "Semua",
                  "all",
                ),

                const SizedBox(width: 10),

                filterButton(
                  "📦 Satuan",
                  "satuan",
                ),

                const SizedBox(width: 10),

                filterButton(
                  "⚖️ Timbang",
                  "timbang",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// GRID
          Expanded(
            child: GridView.builder(
              itemCount:
                  filteredItems.length,

              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount:
                        MediaQuery.of(context)
                                    .size
                                    .width <
                                700
                            ? 2
                            : 3,

                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,

                    childAspectRatio:
                        1.1,
                  ),

              itemBuilder:
                  (context, index) {

                    final item =
                        filteredItems[index];

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(
                            20,
                          ),

                      onTap: () {

                        /// TIMBANG
                        if (item.type ==
                            "timbang") {

                          showDialog(
                            context: context,

                            builder: (_) =>
                                TimbangDialog(
                                  item: item,
                                  provider:
                                      provider,
                                ),
                          );

                        } else {

                          provider
                              .tambahKeCart(
                                item,
                              );
                        }
                      },

                      child: Container(
                        decoration:
                            BoxDecoration(
                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                        0.03,
                                      ),

                                  blurRadius: 10,

                                  offset:
                                      const Offset(
                                        0,
                                        4,
                                      ),
                                ),
                              ],
                            ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                                16,
                              ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              /// TYPE
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal:
                                          12,

                                      vertical:
                                          6,
                                    ),

                                decoration:
                                    BoxDecoration(
                                      color:
                                          item.type ==
                                                  "timbang"
                                              ? Colors
                                                    .orange
                                                    .shade50
                                              : Colors
                                                    .blue
                                                    .shade50,

                                      borderRadius:
                                          BorderRadius.circular(
                                            30,
                                          ),
                                    ),

                                child: Text(
                                  item.type ==
                                          "timbang"
                                      ? "⚖️ ${item.unit}"
                                      : "📦 pcs",

                                  style:
                                      TextStyle(
                                        fontSize:
                                            12,

                                        color:
                                            item.type ==
                                                    "timbang"
                                                ? Colors
                                                      .orange
                                                : Colors
                                                      .blue,

                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                ),
                              ),

                              const Spacer(),

                              /// NAMA
                              Text(
                                item.name,

                                maxLines: 2,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                      fontSize:
                                          17,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              /// HARGA
                              Text(
                                provider
                                    .formatHarga(
                                      item.price,
                                    ),

                                style:
                                    const TextStyle(
                                      color:
                                          Colors
                                              .green,

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize:
                                          18,
                                    ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              /// STOK
                              Text(
                                "Stok : ${provider.formatStock(item)}",

                                style:
                                    TextStyle(
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  /// =====================================
  /// FILTER BUTTON
  /// =====================================
  Widget filterButton(
    String title,
    String value,
  ) {
    final isActive =
        selectedFilter == value;

    return InkWell(
      borderRadius:
          BorderRadius.circular(30),

      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),

        decoration: BoxDecoration(
          color: isActive
              ? Colors.green
              : Colors.white,

          borderRadius:
              BorderRadius.circular(30),
        ),

        child: Text(
          title,

          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.black87,

            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }
}