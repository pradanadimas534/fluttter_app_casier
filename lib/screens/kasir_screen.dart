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

  // Controller untuk DraggableScrollableSheet
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Apakah sheet sedang terbuka penuh / terlihat
  bool _cartVisible = false;

  void _toggleCart() {
    if (_cartVisible) {
      _sheetController.animateTo(
        0.08,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _sheetController.animateTo(
        0.75,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
    setState(() => _cartVisible = !_cartVisible);
  }

  @override
  void dispose() {
    bayarController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KasirProvider>(context);

    final filteredItems = provider.items.where((item) {
      final matchSearch =
          item.name.toLowerCase().contains(search.toLowerCase());
      final matchFilter =
          selectedFilter == "all" || item.type == selectedFilter;
      return matchSearch && matchFilter;
    }).toList();

    final double bayar = double.tryParse(bayarController.text) ?? 0;
    final double kembalian = bayar - provider.total;
    final int cartCount =
        provider.cart.fold(0, (sum, c) => sum + (c.qty as num).toInt());

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("KasirKu",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Tombol keranjang di AppBar — tampilkan badge jumlah item
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _toggleCart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart_rounded, size: 20),
                    if (cartCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      _cartVisible ? "Tutup" : "Keranjang",
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ─── PANEL BARANG (selalu tampil di belakang) ───
          buildLeftPanel(provider, filteredItems),

          // ─── BOTTOM SHEET KERANJANG ───
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.92,
            snap: true,
            snapSizes: const [0.08, 0.75, 0.92],
            builder: (context, scrollController) {
              return _CartSheet(
                scrollController: scrollController,
                sheetController: _sheetController,
                provider: provider,
                bayarController: bayarController,
                bayar: bayar,
                kembalian: kembalian,
                cartCount: cartCount,
                cartVisible: _cartVisible,
                onToggle: _toggleCart,
                onChanged: () => setState(() {}),
                onBayar: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pembayaran berhasil ✓"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  provider.clearCart();
                  bayarController.clear();
                  // Tutup sheet setelah bayar
                  _sheetController.animateTo(0.08,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                  setState(() => _cartVisible = false);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── LEFT PANEL (daftar barang) ───────────────────────────────
  Widget buildLeftPanel(KasirProvider provider, List filteredItems) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        children: [
          // Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari barang...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                filterButton("Semua", "all"),
                const SizedBox(width: 10),
                filterButton("📦 Satuan", "satuan"),
                const SizedBox(width: 10),
                filterButton("⚖️ Timbang", "timbang"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid barang
          Expanded(
            child: GridView.builder(
              itemCount: filteredItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).size.width < 700 ? 2 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (item.type == "timbang") {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            TimbangDialog(item: item, provider: provider),
                      );
                    } else {
                      provider.tambahKeCart(item);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: item.type == "timbang"
                                  ? Colors.orange.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              item.type == "timbang"
                                  ? "⚖️ ${item.unit}"
                                  : "📦 pcs",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.type == "timbang"
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.formatHarga(item.price),
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Stok: ${provider.formatStock(item)}",
                            style:
                                TextStyle(color: Colors.grey.shade600, fontSize: 12),
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

  Widget filterButton(String title, String value) {
    final isActive = selectedFilter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  _CartSheet — Bottom sheet yang bisa di-drag naik/turun
// ─────────────────────────────────────────────────────────────────
class _CartSheet extends StatelessWidget {
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final KasirProvider provider;
  final TextEditingController bayarController;
  final double bayar;
  final double kembalian;
  final int cartCount;
  final bool cartVisible;
  final VoidCallback onToggle;
  final VoidCallback onChanged;
  final VoidCallback onBayar;

  const _CartSheet({
    required this.scrollController,
    required this.sheetController,
    required this.provider,
    required this.bayarController,
    required this.bayar,
    required this.kembalian,
    required this.cartCount,
    required this.cartVisible,
    required this.onToggle,
    required this.onChanged,
    required this.onBayar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          // ── Handle + Header (tidak scroll) ──
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Header bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_rounded,
                          color: Colors.green, size: 22),
                      const SizedBox(width: 10),
                      const Text("Keranjang Belanja",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const Spacer(),
                      // Badge jumlah item
                      if (cartCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            '$cartCount item',
                            style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Tombol buka / tutup
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cartVisible
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_up_rounded,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade100),
              ],
            ),
          ),

          // ── Konten (scrollable) ──
          Expanded(
            child: CartPanel(
              scrollController: scrollController,
              provider: provider,
              bayarController: bayarController,
              bayar: bayar,
              kembalian: kembalian,
              onBayar: onBayar,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}