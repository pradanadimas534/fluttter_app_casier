import 'package:flutter/material.dart';
import '../providers/kasir_provider.dart';

class CartPanel extends StatelessWidget {
  final ScrollController scrollController;
  final KasirProvider provider;
  final TextEditingController bayarController;
  final double bayar;
  final double kembalian;
  final VoidCallback onBayar;
  final VoidCallback onChanged;

  const CartPanel({
    super.key,
    required this.scrollController,
    required this.provider,
    required this.bayarController,
    required this.bayar,
    required this.kembalian,
    required this.onBayar,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        // ── Keranjang kosong ──
        if (provider.cart.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  "Keranjang masih kosong",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                Text(
                  "Ketuk barang untuk menambahkan",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          )
        else ...[
          // ── Daftar item keranjang ──
          ...provider.cart.map((cart) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    // Icon jenis
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cart.type == "timbang"
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          cart.type == "timbang" ? "⚖️" : "📦",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Nama & qty
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cart.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            "${provider.formatQty(cart.qty)} "
                            "${cart.type == 'timbang' ? cart.unit : 'pcs'}"
                            " × ${provider.formatHarga(cart.price)}",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Subtotal + tombol hapus
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          provider.formatHarga(cart.total),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.green),
                        ),
                        GestureDetector(
                          onTap: () => provider.kurangiQty(cart.id),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(Icons.remove_circle_outline,
                                color: Colors.red.shade300, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 8),
        ],

        // ── Ringkasan pembayaran ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .03),
                  blurRadius: 12,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtotal
              _baris("Subtotal", provider.formatHarga(provider.total)),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1)),

              // Total
              _baris(
                "Total Bayar",
                provider.formatHarga(provider.total),
                big: true,
              ),
              const SizedBox(height: 14),

              // Input uang
              TextField(
                controller: bayarController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Uang diterima...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.payments_outlined, color: Colors.grey),
                  suffixIcon: TextButton(
                    onPressed: () {
                      bayarController.text =
                          provider.total.toStringAsFixed(0);
                      onChanged();
                    },
                    child: const Text("Pas",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ),
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: 10),

              // Kembalian
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kembalian < 0
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kembalian < 0
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Kembalian",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: kembalian < 0
                                ? Colors.red.shade700
                                : Colors.green.shade700)),
                    Text(
                      provider.formatHarga(kembalian < 0 ? 0 : kembalian),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: kembalian < 0
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tombol proses
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: provider.cart.isEmpty || bayar < provider.total
                      ? null
                      : onBayar,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text("Proses Pembayaran",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _baris(String label, String value, {bool big = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: big ? 14 : 13,
                fontWeight: big ? FontWeight.bold : FontWeight.w500,
                color: big ? Colors.black87 : Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: big ? 18 : 13,
                fontWeight: FontWeight.bold,
                color: big ? Colors.green.shade700 : Colors.black87)),
      ],
    );
  }
}