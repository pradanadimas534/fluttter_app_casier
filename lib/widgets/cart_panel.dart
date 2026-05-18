import 'package:flutter/material.dart';
import '../providers/kasir_provider.dart';

class CartPanel extends StatelessWidget {
  final KasirProvider provider;
  final TextEditingController bayarController;
  final double bayar;
  final double kembalian;
  final VoidCallback onBayar;
  final VoidCallback onChanged;

  const CartPanel({
    super.key,
    required this.provider,
    required this.bayarController,
    required this.bayar,
    required this.kembalian,
    required this.onBayar,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Kita gunakan CustomScrollView atau gabungan ListView agar seluruh panel aman dari overflow
    return Container(
      color: const Color(0xfff5f7fb),
      child: Column(
        children: [
          /// 1. HEADER (Tetap di atas)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_cart_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  "Keranjang Belanja",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          /// 2. BODY (Daftar Belanjaan + Form Pembayaran dijadikan satu aliran Scroll)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LIST BARANG DI KERANJANG
                  if (provider.cart.isEmpty)
                    Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: Text(
                        "Keranjang kosong",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  else
                    // Menggunakan ListView.builder dengan shrinkWrap agar bisa bersatu di dalam SingleChildScrollView
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.cart.length,
                      itemBuilder: (context, index) {
                        final cart = provider.cart[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cart.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${provider.formatQty(cart.qty)} ${cart.type == "timbang" ? cart.unit : "pcs"} x ${provider.formatHarga(cart.price)}",
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    provider.formatHarga(cart.total),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () => provider.kurangiQty(cart.id),
                                    icon: const Icon(Icons.remove_circle_rounded, color: Colors.red, size: 22),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  /// SECTION RINCIAN PEMBAYARAN (Sekarang ikut nge-scroll kalau layar sempit)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        buildTotalRow("Subtotal", provider.formatHarga(provider.total)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(),
                        ),
                        buildTotalRow("Total Bayar", provider.formatHarga(provider.total), big: true),
                        const SizedBox(height: 12),

                        /// INPUT BAYAR
                        TextField(
                          controller: bayarController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Uang diterima",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                bayarController.text = provider.total.toStringAsFixed(0);
                                onChanged();
                              },
                              icon: const Icon(Icons.payments_rounded),
                            ),
                          ),
                          onChanged: (v) => onChanged(),
                        ),
                        const SizedBox(height: 10),

                        /// KEMBALIAN
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Kembalian", style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                provider.formatHarga(kembalian < 0 ? 0 : kembalian),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        /// BUTTON PROSES
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: provider.cart.isEmpty || bayar < provider.total ? null : onBayar,
                            child: const Text("Proses Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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

  Widget buildTotalRow(String title, String value, {bool big = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: big ? 15 : 13, fontWeight: big ? FontWeight.bold : FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: big ? 18 : 14, fontWeight: FontWeight.bold, color: big ? Colors.green : Colors.black)),
      ],
    );
  }
}