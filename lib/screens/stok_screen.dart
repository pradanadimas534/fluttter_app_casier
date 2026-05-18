import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../providers/kasir_provider.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  String selectedType = "satuan";
  String selectedUnit = "pcs";

  @override
  Widget build(BuildContext context) {

    final provider =
        Provider.of<KasirProvider>(context);

    /// TOTAL BARANG
    int totalBarang =
        provider.items.length;

    /// STOK MENIPIS
    int stokMenipis = provider.items.where(
      (e) => e.stock > 0 && e.stock <= 5,
    ).length;

    /// STOK HABIS
    int stokHabis = provider.items.where(
      (e) => e.stock <= 0,
    ).length;

    /// LIST RESTOCK
    List<ItemModel> restockList =
        provider.items.where(
      (e) => e.stock <= 5,
    ).toList();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Manajemen Stok",
        ),
      ),

      body: Row(
        children: [

          /// KIRI
          Expanded(
            flex: 2,

            child: SingleChildScrollView(

              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  /// TITLE
                  const Text(
                    "Tambah Barang Baru",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// CARD FORM
                  Card(

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          /// PILIH TYPE
                          Row(
                            children: [

                              const Text(
                                "Jenis : ",
                              ),

                              const SizedBox(width: 10),

                              ChoiceChip(
                                label:
                                    const Text("📦 Satuan"),

                                selected:
                                    selectedType ==
                                        "satuan",

                                onSelected: (v) {

                                  setState(() {
                                    selectedType =
                                        "satuan";

                                    selectedUnit =
                                        "pcs";
                                  });
                                },
                              ),

                              const SizedBox(width: 10),

                              ChoiceChip(
                                label: const Text(
                                  "⚖️ Timbang",
                                ),

                                selected:
                                    selectedType ==
                                        "timbang",

                                onSelected: (v) {

                                  setState(() {
                                    selectedType =
                                        "timbang";

                                    selectedUnit =
                                        "gram";
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// NAMA
                          TextField(
                            controller:
                                nameController,

                            decoration:
                                const InputDecoration(

                              labelText:
                                  "Nama Barang",

                              border:
                                  OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// HARGA
                          TextField(
                            controller:
                                priceController,

                            keyboardType:
                                TextInputType.number,

                            decoration:
                                InputDecoration(

                              labelText:
                                  selectedType ==
                                          "satuan"

                                      ? "Harga (Rp/pcs)"
                                      : "Harga",

                              border:
                                  const OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// UNIT
                          if (selectedType ==
                              "timbang")

                            Column(
                              children: [

                                DropdownButtonFormField(
                                  initialValue: selectedUnit,

                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        "Satuan Harga",

                                    border:
                                        OutlineInputBorder(),
                                  ),

                                  items: const [

                                    DropdownMenuItem(
                                      value: "gram",
                                      child: Text(
                                        "Per Gram",
                                      ),
                                    ),

                                    DropdownMenuItem(
                                      value: "ons",
                                      child: Text(
                                        "Per Ons",
                                      ),
                                    ),

                                    DropdownMenuItem(
                                      value: "kg",
                                      child: Text(
                                        "Per KG",
                                      ),
                                    ),
                                  ],

                                  onChanged: (v) {

                                    setState(() {
                                      selectedUnit =
                                          v!;
                                    });
                                  },
                                ),

                                const SizedBox(
                                  height: 16,
                                ),
                              ],
                            ),

                          /// STOK
                          TextField(
                            controller:
                                stockController,

                            keyboardType:
                                TextInputType.number,

                            decoration:
                                InputDecoration(

                              labelText:
                                  selectedType ==
                                          "satuan"

                                      ? "Stok (pcs)"
                                      : "Stok ($selectedUnit)",

                              border:
                                  const OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// BUTTON
                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(

                              style:
                                  ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.all(
                                  16,
                                ),
                              ),

                              onPressed: () {

                                if (nameController
                                    .text
                                    .isEmpty) {
                                  return;
                                }

                                provider.items.add(

                                  ItemModel(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch,

                                    name:
                                        nameController.text,

                                    price: double.parse(
                                      priceController
                                          .text,
                                    ),

                                    stock: double.parse(
                                      stockController
                                          .text,
                                    ),

                                    sold: 0,

                                    type:
                                        selectedType,

                                    unit:
                                        selectedUnit,
                                  ),
                                );

                                // ignore: invalid_use_of_protected_member
                                provider.notifyListeners();

                                nameController.clear();
                                priceController.clear();
                                stockController.clear();
                              },

                              child: const Text(
                                "+ Tambah Barang",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// TABLE TITLE
                  const Text(
                    "Daftar Semua Barang",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TABLE
                  Card(

                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,

                      child: DataTable(

                        columns: const [

                          DataColumn(
                            label: Text("Nama"),
                          ),

                          DataColumn(
                            label: Text("Jenis"),
                          ),

                          DataColumn(
                            label: Text("Harga"),
                          ),

                          DataColumn(
                            label: Text("Stok"),
                          ),
                        ],

                        rows: provider.items.map((item) {

                          return DataRow(

                            cells: [

                              DataCell(
                                Text(item.name),
                              ),

                              DataCell(
                                Text(item.type),
                              ),

                              DataCell(
                                Text(
                                  "Rp ${item.price.toStringAsFixed(0)}",
                                ),
                              ),

                              DataCell(
                                Text(
                                  "${item.stock} ${item.unit}",
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// KANAN
          Container(
            width: 350,

            color: Colors.white,

            child: SingleChildScrollView(

              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Status Stok",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// SUMMARY
                  Row(
                    children: [

                      Expanded(
                        child: summaryCard(
                          "Total Barang",
                          "$totalBarang",
                          Colors.green,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: summaryCard(
                          "Menipis",
                          "$stokMenipis",
                          Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: summaryCard(
                          "Habis",
                          "$stokHabis",
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Perlu Restock Segera",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  restockList.isEmpty

                      ? const Center(
                          child: Text(
                            "Semua stok aman 😎",
                          ),
                        )

                      : Column(

                          children:
                              restockList.map((item) {

                            return Card(

                              child: ListTile(

                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.orange
                                          .shade100,

                                  child: const Icon(
                                    Icons.warning,
                                    color:
                                        Colors.orange,
                                  ),
                                ),

                                title: Text(
                                  item.name,
                                ),

                                subtitle: Text(
                                  "Sisa stok : ${item.stock}",
                                ),

                                trailing: Text(
                                  item.stock <= 0
                                      ? "Habis"
                                      : "Menipis",

                                  style: TextStyle(
                                    color:
                                        item.stock <= 0
                                            ? Colors.red
                                            : Colors.orange,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryCard(
    String title,
    String value,
    Color color,
  ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),

        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        children: [

          Text(
            title,

            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}