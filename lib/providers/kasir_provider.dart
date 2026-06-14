import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/item_model.dart';
import '../models/cart_model.dart';
import '../services/auth_service.dart';
import '../services/csv_local_service.dart';
import '../services/storage_service.dart';
import '../models/transaction_model.dart';

class KasirProvider extends ChangeNotifier {
  final _auth    = AuthService();
  final _local   = CsvLocalService();
  final _storage = StorageService();

  // ── STATE ────────────────────────────────────────────────────────
  List<ItemModel> items = [];
  List<CartModel> cart  = [];
  List<TransactionModel> transactions = [];

  bool   isLoading     = true;
  bool   isLoggedIn    = false;
  String backupStatus  = '';
  int    _nextId       = 1;

  StreamSubscription? _authSub;
  Timer?              _backupTimer;

  // ── FORMAT ───────────────────────────────────────────────────────
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  String formatHarga(double v) => _rupiah.format(v);

  String formatQty(double qty) =>
      qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);

  String formatStock(ItemModel item) {
    if (item.type == 'timbang') return '${item.stock.toStringAsFixed(0)} ${item.unit}';
    return '${item.stock.toStringAsFixed(0)} pcs';
  }

  String fmtStok(ItemModel item) => '${item.stock} ${item.unit}';

  // ── STATUS STOK ──────────────────────────────────────────────────
  double getThreshold(ItemModel item) {
    if (item.type == 'timbang') {
      if (item.unit == 'gram') return 500;
      if (item.unit == 'ons')  return 5;
      return 1;
    }
    return 5;
  }

  String getStatus(ItemModel item) {
    if (item.stock <= 0)                  return 'Habis';
    if (item.stock <= getThreshold(item)) return 'Menipis';
    return 'Aman';
  }

  Color getStatusColor(ItemModel item) {
    if (item.stock <= 0)                  return Colors.red;
    if (item.stock <= getThreshold(item)) return Colors.orange;
    return Colors.green;
  }

  // ── INFO USER ────────────────────────────────────────────────────
  String get userName  => _auth.userName  ?? 'Pengguna';
  String get userEmail => _auth.userEmail ?? '';
  String get userPhoto => _auth.userPhoto ?? '';

  // ── INIT ─────────────────────────────────────────────────────────
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    // Dengarkan perubahan status login Firebase
    _authSub = _auth.userStream.listen((user) async {
      isLoggedIn = user != null;

      if (user != null) {
        await _onLogin(user);
      } else {
        await _onLogout();
      }
    });
  }

  // ── SAAT LOGIN ───────────────────────────────────────────────────
  Future<void> _onLogin(User user) async {
    isLoading = true;
    notifyListeners();

    final hasLocal = await _local.hasLocalFile;

    if (hasLocal) {
      // Ada data lokal → pakai langsung
      await _loadLocal();
      backupStatus = 'Data lokal dimuat ✓';

      // Cek di background apakah perlu sync dari cloud
      // (misal: HP baru atau install ulang)
      _syncFromCloudIfNewer(user.uid);
    } else {
      // Tidak ada data lokal → coba restore dari Firebase Storage
      backupStatus = 'Mencari backup di cloud...';
      notifyListeners();

      await _restoreFromCloud(user.uid);
    }

    // Mulai jadwal backup otomatis tiap 1 jam (backup jika sudah 24 jam)
    _mulaiJadwalBackup(user.uid);

    isLoading = false;
    notifyListeners();
  }

  // ── SAAT LOGOUT ──────────────────────────────────────────────────
  Future<void> _onLogout() async {
    _backupTimer?.cancel();
    items        = [];
    cart         = [];
    backupStatus = '';
    isLoading    = false;
    notifyListeners();
  }

  // ── LOAD DATA LOKAL ──────────────────────────────────────────────
  Future<void> _loadLocal() async {
    items = await _local.readAll();
    _recalcNextId();
    notifyListeners();
  }

  // ── RESTORE DARI FIREBASE STORAGE ────────────────────────────────
  Future<void> _restoreFromCloud(String uid) async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      backupStatus = 'Offline — tidak ada data lokal';
      items        = [];
      isLoading    = false;
      notifyListeners();
      return;
    }

    final csvContent = await _storage.download(uid);
    if (csvContent != null) {
      // Tulis CSV dari cloud ke lokal
      await _local.writeRaw(csvContent);
      await _loadLocal();
      backupStatus = 'Data berhasil dipulihkan dari cloud ✓';
    } else {
      // Belum pernah backup → mulai dari kosong
      items        = [];
      backupStatus = 'Mulai baru — belum ada backup';
    }
    notifyListeners();
  }

  // ── SYNC DARI CLOUD JIKA LEBIH BARU ─────────────────────────────
  // Dipanggil di background — tidak block UI
  Future<void> _syncFromCloudIfNewer(String uid) async {
    // Hanya sync jika online
    if (!await _isOnline()) return;

    // Cek metadata cloud
    final hasCloud = await _storage.hasCloudBackup(uid);
    if (!hasCloud) return;

    // Cukup upload lokal ke cloud saja
    // (lokal adalah sumber kebenaran, cloud adalah backup)
    await _doBackup(uid);
  }

  // ── JADWAL BACKUP ────────────────────────────────────────────────
  void _mulaiJadwalBackup(String uid) {
    _backupTimer?.cancel();
    // Cek tiap 1 jam, backup jika sudah 24 jam
    _backupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cekDanBackup(uid),
    );
    // Cek langsung pertama kali
    _cekDanBackup(uid);
  }

  Future<void> _cekDanBackup(String uid) async {
    if (!await _isOnline())            return;
    if (!await _storage.needsBackup)   return;
    await _doBackup(uid);
  }

  Future<void> _doBackup(String uid) async {
    final path   = await _local.filePath;
    final result = await _storage.upload(uid, path);

    switch (result) {
      case BackupResult.sukses:
        final last = await _storage.getLastBackupTime();
        backupStatus = 'Backup: ${_fmtWaktu(last)}';
        break;
      case BackupResult.offline:
        backupStatus = 'Backup tertunda (offline)';
        break;
      case BackupResult.fileTidakAda:
      case BackupResult.gagal:
        backupStatus = 'Backup gagal';
        break;
    }
    notifyListeners();
  }

  // ── BACKUP MANUAL ────────────────────────────────────────────────
  Future<void> backupManual() async {
    final uid = _auth.uid;
    if (uid == null) return;

    backupStatus = 'Membackup...';
    notifyListeners();

    if (!await _isOnline()) {
      backupStatus = 'Tidak ada koneksi internet';
      notifyListeners();
      return;
    }

    await _doBackup(uid);
  }

  // ── LOGIN ────────────────────────────────────────────────────────
  Future<bool> login() async {
    isLoading    = true;
    backupStatus = '';
    notifyListeners();

    final user = await _auth.signInWithGoogle();
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return false;
    }
    return true;
    // _onLogin dipanggil otomatis dari _authSub
  }

  // ── LOGOUT ───────────────────────────────────────────────────────
  Future<void> logout() async {
    // Backup dulu sebelum logout jika online
    final uid = _auth.uid;
    if (uid != null && await _isOnline()) {
      await _doBackup(uid);
    }
    _backupTimer?.cancel();
    await _auth.signOut();
    // _onLogout dipanggil otomatis dari _authSub
  }

  // ── CART: TAMBAH ─────────────────────────────────────────────────
  void tambahKeCart(ItemModel item, {double qty = 1}) {
    if (item.stock < qty) return;

    final index = cart.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      cart[index].qty   += qty;
      cart[index].total  = cart[index].qty * cart[index].price;
    } else {
      cart.add(CartModel(
        id: item.id, name: item.name,
        type: item.type, unit: item.unit,
        price: item.price, qty: qty,
        total: item.price * qty,
      ));
    }
    item.stock -= qty;
    notifyListeners();
  }

  // ── CART: KURANGI QTY ────────────────────────────────────────────
  void kurangiQty(int id) {
    final index = cart.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final step    = cart[index].type == 'timbang' ? 0.1 : 1.0;
    final itemIdx = items.indexWhere((e) => e.id == id);
    if (itemIdx != -1) items[itemIdx].stock += step;

    cart[index].qty -= step;
    if (cart[index].qty <= 0) {
      cart.removeAt(index);
    } else {
      cart[index].total = cart[index].qty * cart[index].price;
    }
    notifyListeners();
  }

  // ── CART: CLEAR ──────────────────────────────────────────────────
  void clearCart() {
    for (final c in cart) {
      final idx = items.indexWhere((e) => e.id == c.id);
      if (idx != -1) items[idx].stock += c.qty;
    }
    cart.clear();
    notifyListeners();
  }

  double get total => cart.fold(0.0, (s, c) => s + c.total);

  // ── PROSES BAYAR ─────────────────────────────────────────────────
  Future<void> prosesPembayaran() async {
    for (final c in cart) {
      final idx = items.indexWhere((i) => i.id == c.id);
      if (idx < 0) continue;
      items[idx].sold += c.qty;
    }
    await _local.writeAll(items); // simpan lokal dulu
    cart.clear();
    notifyListeners();

    // Cek backup di background (tidak block UI)
    final uid = _auth.uid;
    if (uid != null) _cekDanBackup(uid);
  }

 // ── STATISTIK ────────────────────────────────────────────────────

int get totalBarang => items.length;

int get stokMenipis =>
    items.where(
      (e) => e.stock > 0 && e.stock <= getThreshold(e),
    ).length;

int get stokHabis =>
    items.where((e) => e.stock <= 0).length;

/// Jumlah transaksi yang pernah terjadi
int get totalTransaksi =>
    transactions.length;

/// Total item yang terjual
int get totalItemTerjual =>
    items.fold(
      0,
      (s, e) => s + e.sold.toInt(),
    );

/// Total pendapatan dari transaksi
double get totalPendapatan =>
    transactions.fold(
      0.0,
      (sum, trx) => sum + trx.total,
    );

List<ItemModel> get barangTerlaris {
  final sorted = List<ItemModel>.from(items)
    ..sort((a, b) => b.sold.compareTo(a.sold));

  return sorted.take(5).toList();
}

List<ItemModel> get restockList =>
    items.where(
      (e) => e.stock <= getThreshold(e),
    ).toList();

  // ── MANAJEMEN BARANG ─────────────────────────────────────────────
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

    items.add(ItemModel(
      id: _nextId++, name: name,
      price: price, stock: stock,
      sold: 0, type: type, unit: unit,
    ));
    await _local.writeAll(items);
    notifyListeners();

    final uid = _auth.uid;
    if (uid != null) _cekDanBackup(uid);
  }

  Future<void> hapusItem(int id) async {
    items.removeWhere((e) => e.id == id);
    cart.removeWhere((e) => e.id == id);
    await _local.writeAll(items);
    notifyListeners();

    final uid = _auth.uid;
    if (uid != null) _cekDanBackup(uid);
  }

  Future<void> ubahStok(int id, double value) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx].stock = value < 0 ? 0 : value;
    await _local.writeAll(items);
    notifyListeners();
  }

  Future<void> ubahHarga(int id, double value) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx].price = value < 0 ? 0 : value;
    await _local.writeAll(items);
    notifyListeners();
  }

  // ── HELPER ───────────────────────────────────────────────────────
  void _recalcNextId() {
    if (items.isEmpty) {
      _nextId = 1;
    } else {
      _nextId = items.map((i) => i.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  String _fmtWaktu(DateTime? dt) {
    if (dt == null) return '-';
    final d = dt.toLocal();
    return '${_p(d.day)}/${_p(d.month)}/${d.year} ${_p(d.hour)}:${_p(d.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    _authSub?.cancel();
    _backupTimer?.cancel();
    super.dispose();
  }
}