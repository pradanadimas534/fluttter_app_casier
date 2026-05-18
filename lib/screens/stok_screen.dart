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
    final provider = Provider.of<KasirProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text("Manajemen Stok"),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          bool mobile = constraints.maxWidth < 900;

          return mobile ? buildMobile(provider) : buildDesktop(provider);
        },
      ),
    );
  }

  /// DESKTOP
  Widget buildDesktop(KasirProvider provider) {
    return Row(
      children: [
        /// LEFT
        Expanded(
          flex: 2,

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                buildFormCard(provider),

                const SizedBox(height: 20),

                buildTableCard(provider),
              ],
            ),
          ),
        ),

        /// RIGHT
        Container(
          width: 360,

          padding: const EdgeInsets.all(16),

          child: buildRightPanel(provider),
        ),
      ],
    );
  }

  /// MOBILE
  Widget buildMobile(KasirProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          buildFormCard(provider),

          const SizedBox(height: 20),

          buildRightPanel(provider),

          const SizedBox(height: 20),

          buildTableCard(provider),
        ],
      ),
    );
  }

  /// FORM
  Widget buildFormCard(KasirProvider provider) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Tambah Barang Baru",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// TYPE
            Row(
              children: [
                Expanded(
                  child: buildTypeButton(
                    "📦 Satuan",
                    selectedType == "satuan",
                    () {
                      setState(() {
                        selectedType = "satuan";

                        selectedUnit = "pcs";
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: buildTypeButton(
                    "⚖️ Timbang",
                    selectedType == "timbang",
                    () {
                      setState(() {
                        selectedType = "timbang";

                        selectedUnit = "gram";
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// NAMA
            TextField(
              controller: nameController,

              decoration: inputStyle("Nama Barang"),
            ),

            const SizedBox(height: 16),

            /// HARGA
            TextField(
              controller: priceController,

              keyboardType: TextInputType.number,

              decoration: inputStyle(
                selectedType == "satuan" ? "Harga (Rp/pcs)" : "Harga",
              ),
            ),

            const SizedBox(height: 16),

            /// UNIT
            if (selectedType == "timbang")
              Column(
                children: [
                  DropdownButtonFormField(
                    value: selectedUnit,

                    decoration: inputStyle("Satuan Harga"),

                    borderRadius: BorderRadius.circular(14),

                    items: const [
                      DropdownMenuItem(value: "gram", child: Text("Per Gram")),

                      DropdownMenuItem(value: "ons", child: Text("Per Ons")),

                      DropdownMenuItem(value: "kg", child: Text("Per KG")),
                    ],

                    onChanged: (v) {
                      setState(() {
                        selectedUnit = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),

            /// STOCK
            TextField(
              controller: stockController,

              keyboardType: TextInputType.number,

              decoration: inputStyle(
                selectedType == "satuan"
                    ? "Stok (pcs)"
                    : "Stok ($selectedUnit)",
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.all(18),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                onPressed: () {
                  if (nameController.text.isEmpty ||
                      priceController.text.isEmpty) {
                    return;
                  }

                  provider.addItem(
                    name: nameController.text,

                    price: double.parse(priceController.text),

                    stock: double.parse(stockController.text),

                    type: selectedType,

                    unit: selectedUnit,
                  );

                  nameController.clear();
                  priceController.clear();
                  stockController.clear();
                },

                child: const Text("+ Tambah Barang"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TABLE
  Widget buildTableCard(KasirProvider provider) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Daftar Semua Barang",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: DataTable(

  columnSpacing: 24,
  horizontalMargin: 12,

  headingRowHeight: 56,
  dataRowMinHeight: 70,
  dataRowMaxHeight: 80,

  headingRowColor:
      WidgetStateProperty.all(
    Colors.grey.shade100,
  ),

  border: TableBorder(

    horizontalInside: BorderSide(
      color: Colors.grey.shade200,
    ),
  ),

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

    DataColumn(
      label: Text("Aksi"),
    ),
  ],

  rows: provider.items.map((item) {

    return DataRow(

      cells: [

        /// NAMA
        DataCell(

          SizedBox(
            width: 150,

            child: Text(

              item.name,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ),

        /// JENIS
        DataCell(

          Container(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            decoration: BoxDecoration(

              color:
                  item.type == "timbang"

                      ? Colors.orange.shade50

                      : Colors.blue.shade50,

              borderRadius:
                  BorderRadius.circular(
                30,
              ),
            ),

            child: Text(

              item.type == "timbang"

                  ? "⚖️ ${item.unit}"

                  : "📦 pcs",

              style: TextStyle(

                color:
                    item.type == "timbang"

                        ? Colors.orange

                        : Colors.blue,

                fontWeight:
                    FontWeight.bold,

                fontSize: 12,
              ),
            ),
          ),
        ),

        /// HARGA
        DataCell(

          Text(

            provider.formatHarga(
              item.price,
            ),

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        /// STOK
        DataCell(

          Container(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            decoration: BoxDecoration(

              color: provider
                  .getStatusColor(item)
                  .withValues(alpha: 0.12),

              borderRadius:
                  BorderRadius.circular(
                30,
              ),
            ),

            child: Text(

              provider.formatStock(
                item,
              ),

              style: TextStyle(

                color:
                    provider.getStatusColor(
                  item,
                ),

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),

        /// AKSI
        DataCell(

          SizedBox(

            width: 110,

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment.start,

              children: [

                /// EDIT
                Material(

                  color: Colors.orange
                      .shade50,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  child: InkWell(

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    onTap: () {

                      showEditDialog(
                        context,
                        provider,
                        item,
                      );
                    },

                    child: const Padding(

                      padding:
                          EdgeInsets.all(8),

                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// DELETE
                Material(

                  color:
                      Colors.red.shade50,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  child: InkWell(

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),

                    onTap: () {

                      provider.hapusItem(
                        item.id,
                      );
                    },

                    child: const Padding(

                      padding:
                          EdgeInsets.all(8),

                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }).toList(),
),
            ),
          ],
        ),
      ),
    );
  }

  /// RIGHT PANEL
  Widget buildRightPanel(KasirProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        /// SUMMARY
        Row(
          children: [
            Expanded(
              child: summaryCard(
                "Total",
                "${provider.totalBarang}",
                Colors.green,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: summaryCard(
                "Menipis",
                "${provider.stokMenipis}",
                Colors.orange,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: summaryCard("Habis", "${provider.stokHabis}", Colors.red),
            ),
          ],
        ),

        const SizedBox(height: 24),

        const Text(
          "Perlu Restock",

          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        provider.restockList.isEmpty
            ? Card(
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Padding(
                  padding: EdgeInsets.all(20),

                  child: Center(child: Text("✅ Semua stok aman")),
                ),
              )
            : Column(
                children: provider.restockList.map((item) {
                  return Card(
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,

                        child: const Icon(Icons.warning, color: Colors.orange),
                      ),

                      title: Text(item.name),

                      subtitle: Text(provider.fmtStok(item)),

                      trailing: Text(
                        provider.getStatus(item),

                        style: TextStyle(
                          color: provider.getStatusColor(item),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  /// SUMMARY CARD
  Widget summaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12)),

          const SizedBox(height: 8),

          Text(
            value,

            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// TYPE BUTTON
  Widget buildTypeButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.grey.shade100,

          borderRadius: BorderRadius.circular(14),
        ),

        child: Center(
          child: Text(
            text,

            style: TextStyle(
              color: active ? Colors.white : Colors.black,

              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// INPUT STYLE
  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,

      filled: true,

      fillColor: Colors.grey.shade100,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide.none,
      ),
    );
  }

  void showEditDialog(
    BuildContext context,
    KasirProvider provider,
    ItemModel item,
  ) {
    final hargaController = TextEditingController(
      text: item.price.toStringAsFixed(0),
    );

    final stokController = TextEditingController(
      text: item.stock.toStringAsFixed(0),
    );

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text("Edit ${item.name}"),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              /// HARGA
              TextField(
                controller: hargaController,

                keyboardType: TextInputType.number,

                decoration: InputDecoration(
                  labelText: "Harga",

                  filled: true,

                  fillColor: Colors.grey.shade100,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// STOCK
              TextField(
                controller: stokController,

                keyboardType: TextInputType.number,

                decoration: InputDecoration(
                  labelText: "Stok (${item.unit})",

                  filled: true,

                  fillColor: Colors.grey.shade100,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),

                    borderSide: BorderSide.none,
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),

              onPressed: () {
                provider.ubahHarga(
                  item.id,

                  double.tryParse(hargaController.text) ?? 0,
                );

                provider.ubahStok(
                  item.id,

                  double.tryParse(stokController.text) ?? 0,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${item.name} diperbarui ✓")),
                );
              },

              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}
