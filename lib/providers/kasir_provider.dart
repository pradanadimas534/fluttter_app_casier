import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item_model.dart';
import '../models/cart_model.dart';
import '../services/csv_storage_service.dart';
import '../services/google_drive_service.dart';

class KasirProvider extends ChangeNotifier {
  // ── SERVICE ─────────────────────────────────────────────────────
  final _csv   = CsvStorageService();
  final _drive = GoogleDriveService();

  // ── STATE ────────────────────────────────────────────────────────
  List<ItemModel> items = [];
  List<CartModel> cart  = [];

  bool   isLoading   = true;
  String driveStatus = '';

  Timer? _driveTimer;

  // ── FORMAT ───────────────────────────────────────────────────────
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String formatHarga(double value) => rupiah.format(value);

  String formatQty(double qty) =>
      qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);

  String formatStock(ItemModel item) {
    if (item.type == 'timbang') {
      return '${item.stock.toStringAsFixed(0)} ${item.unit}';
    }
    return '${item.stock.toStringAsFixed(0)} pcs';
  }

  String fmtStok(ItemModel item) => '${item.stock} ${item.unit}';

  // ── STATUS STOK ──────────────────────────────────────────────────
  double getThreshold(ItemModel item) {
    if (item.type == 'timbang') {
      if (item.unit == 'gram') return 500;
      if (item.unit == 'ons')  return 5;
      return 1; // kg
    }
    return 5;
  }

  String getStatus(ItemModel item) {
    if (item.stock <= 0)               return 'Habis';
    if (item.stock <= getThreshold(item)) return 'Menipis';
    return 'Aman';
  }

  Color getStatusColor(ItemModel item) {
    if (item.stock <= 0)               return Colors.red;
    if (item.stock <= getThreshold(item)) return Colors.orange;
    return Colors.green;
  }

  // ── INIT ─────────────────────────────────────────────────────────
  /// Panggil sekali di main():
  ///   ChangeNotifierProvider(create: (_) => KasirProvider()..init())
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    // Baca dari CSV lokal (jika belum ada → tulis data default)
    items = await _csv.readAll();
    await _csv.writeAll(items); // pastikan file CSV selalu ada

    // Cek status Drive terakhir
    await _refreshDriveStatus();

    // Jadwal upload otomatis tiap 24 jam
    _mulaiJadwalDrive();

    isLoading = false;
    notifyListeners();
  }

  // ── CART: TAMBAH ─────────────────────────────────────────────────
  void tambahKeCart(ItemModel item, {double qty = 1}) {
    if (item.stock < qty) return; // stok tidak cukup

    final index = cart.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      cart[index].qty   += qty;
      cart[index].total  = cart[index].qty * cart[index].price;
    } else {
      cart.add(CartModel(
        id:    item.id,
        name:  item.name,
        type:  item.type,
        unit:  item.unit,
        price: item.price,
        qty:   qty,
        total: item.price * qty,
      ));
    }

    // Kurangi stok tampilan (di memori dulu, CSV diupdate saat bayar)
    item.stock -= qty;

    notifyListeners();
  }

  // ── CART: KURANGI QTY ────────────────────────────────────────────
  void kurangiQty(int id) {
    final index = cart.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final step = cart[index].type == 'timbang' ? 0.1 : 1.0;
    cart[index].qty -= step;

    if (cart[index].qty <= 0) {
      // Kembalikan stok ke item
      final itemIdx = items.indexWhere((e) => e.id == id);
      if (itemIdx != -1) {
        items[itemIdx].stock += cart[index].qty.abs() + step;
      }
      cart.removeAt(index);
    } else {
      cart[index].total = cart[index].qty * cart[index].price;
      // Kembalikan 1 stok ke item
      final itemIdx = items.indexWhere((e) => e.id == id);
      if (itemIdx != -1) items[itemIdx].stock += step;
    }

    notifyListeners();
  }

  // ── CART: CLEAR ──────────────────────────────────────────────────
  void clearCart() {
    // Kembalikan semua stok ke item
    for (final c in cart) {
      final idx = items.indexWhere((e) => e.id == c.id);
      if (idx != -1) items[idx].stock += c.qty;
    }
    cart.clear();
    notifyListeners();
  }

  // ── TOTAL ────────────────────────────────────────────────────────
  double get total => cart.fold(0.0, (s, c) => s + c.total);

  // ── PROSES BAYAR ─────────────────────────────────────────────────
  /// Kurangi stok permanen di CSV + update sold
  Future<void> prosesPembayaran() async {
    for (final c in cart) {
      final idx = items.indexWhere((i) => i.id == c.id);
      if (idx < 0) continue;

      // Stok sudah dikurangi saat tambahKeCart,
      // yang perlu diupdate hanya sold
      items[idx].sold += c.qty;
    }

    // Tulis ulang CSV → data aman
    await _csv.writeAll(items);
    cart.clear();

    // Cek apakah perlu upload ke Drive
    _cekUploadDrive();

    notifyListeners();
  }

  // ── RINGKASAN / STATISTIK ────────────────────────────────────────
  int get totalBarang      => items.length;
  int get stokMenipis      => items.where((e) => e.stock > 0 && e.stock <= getThreshold(e)).length;
  int get stokHabis        => items.where((e) => e.stock <= 0).length;
  int get totalTransaksi   => 15; // TODO: sambungkan ke tabel transaksi jika perlu
  int get totalItemTerjual => items.fold(0, (s, e) => s + e.sold.toInt());

  double get totalPendapatan =>
      items.fold(0.0, (s, e) => s + e.price * e.sold);

  List<ItemModel> get barangTerlaris {
    final sorted = List<ItemModel>.from(items)
      ..sort((a, b) => b.sold.compareTo(a.sold));
    return sorted.take(5).toList();
  }

  List<ItemModel> get restockList =>
      items.where((e) => e.stock <= getThreshold(e)).toList();

  // ── MANAJEMEN BARANG ─────────────────────────────────────────────
  int nextId = 100;

  String newItemType = 'satuan';
  void setNewType(String type) {
    newItemType = type;
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required double price,
    required double stock,
    required String type,
    required String unit,
  }) async {
    if (name.isEmpty || price <= 0) return;

    final newItem = ItemModel(
      id:    nextId++,
      name:  name,
      price: price,
      stock: stock,
      sold:  0,
      type:  type,
      unit:  unit,
    );

    items.add(newItem);

    // Langsung simpan ke CSV
    await _csv.writeAll(items);
    _cekUploadDrive();

    notifyListeners();
  }

  Future<void> hapusItem(int id) async {
    items.removeWhere((e) => e.id == id);
    cart.removeWhere((e) => e.id == id);

    await _csv.writeAll(items);
    _cekUploadDrive();

    notifyListeners();
  }

  Future<void> ubahStok(int id, double value) async {
    final item = items.firstWhere((e) => e.id == id);
    item.stock = value < 0 ? 0 : value;

    await _csv.writeAll(items);
    _cekUploadDrive();

    notifyListeners();
  }

  Future<void> ubahHarga(int id, double value) async {
    final item = items.firstWhere((e) => e.id == id);
    item.price = value < 0 ? 0 : value;

    await _csv.writeAll(items);
    _cekUploadDrive();

    notifyListeners();
  }

  // ── GOOGLE DRIVE ─────────────────────────────────────────────────
  bool   get isDriveConnected => _drive.isSignedIn;
  String get driveEmail       => _drive.userEmail ?? '';

  Future<void> loginDrive(BuildContext context) async {
    driveStatus = 'Menghubungkan ke Google...';
    notifyListeners();

    final ok = await _drive.signIn(context);
    if (ok) {
      // Upload langsung setelah login
      await _uploadDrive();
    } else {
      driveStatus = 'Login dibatalkan';
      notifyListeners();
    }
  }

  Future<void> logoutDrive() async {
    await _drive.signOut();
    driveStatus = 'Akun Google dilepas';
    notifyListeners();
  }

  Future<void> uploadDriveManual() async => _uploadDrive();

  // ── DRIVE INTERNAL ───────────────────────────────────────────────
  void _mulaiJadwalDrive() {
    _cekUploadDrive(); // cek langsung saat buka app
    _driveTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cekUploadDrive(),
    );
  }

  Future<void> _cekUploadDrive() async {
    final ok = await _drive.signInSilently();
    if (!ok) return; // belum login → skip, tidak error

    final last = await _drive.getLastUploadTime();
    final perlu = last == null ||
        DateTime.now().difference(last).inHours >= 24;

    if (perlu) await _uploadDrive();
  }

  Future<void> _uploadDrive() async {
    driveStatus = 'Mengupload ke Google Drive...';
    notifyListeners();

    final path   = await _csv.filePath;
    final result = await _drive.uploadFile(path);

    switch (result) {
      case UploadResult.sukses:
        final last = await _drive.getLastUploadTime();
        driveStatus = 'Terakhir upload: ${_fmtWaktu(last)}';
        break;
      case UploadResult.belumLogin:
        driveStatus = 'Belum terhubung ke Google Drive';
        break;
      case UploadResult.fileTidakAda:
        driveStatus = 'File CSV tidak ditemukan';
        break;
      case UploadResult.gagal:
        driveStatus = 'Upload gagal, coba lagi';
        break;
    }
    notifyListeners();
  }

  Future<void> _refreshDriveStatus() async {
    final ok = await _drive.signInSilently();
    if (!ok) {
      driveStatus = 'Belum terhubung ke Google Drive';
      return;
    }
    final last = await _drive.getLastUploadTime();
    driveStatus = last != null
        ? 'Terakhir upload: ${_fmtWaktu(last)}'
        : 'Terhubung: ${_drive.userEmail} (belum pernah upload)';
  }

  // ── HELPER ───────────────────────────────────────────────────────
  String _fmtWaktu(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    return '${_p(d.day)}/${_p(d.month)}/${d.year} ${_p(d.hour)}:${_p(d.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    _driveTimer?.cancel();
    super.dispose();
  }
}