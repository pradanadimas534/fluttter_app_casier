import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/item_model.dart';

/// Semua data barang disimpan sebagai file CSV lokal.
/// File ini adalah SUMBER KEBENARAN — setiap perubahan langsung tulis ulang.
/// Google Drive tinggal upload file ini tiap 24 jam.
class CsvStorageService {
  static final CsvStorageService _i = CsvStorageService._();
  factory CsvStorageService() => _i;
  CsvStorageService._();

  static const _fileName = 'kasirku_data.csv';

  // ── PATH FILE ────────────────────────────────────────────────────
  Future<File> get _file async {
    final dir = await _getDir();
    return File('${dir.path}/$_fileName');
  }

  Future<String> get filePath async => (await _file).path;

  Future<Directory> _getDir() async {
    late Directory dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Documents/KasirKu');
    } else if (Platform.isIOS) {
      final base = await getApplicationDocumentsDirectory();
      dir = Directory('${base.path}/KasirKu');
    } else {
      // Windows / Desktop
      final base = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      dir = Directory('${base.path}/KasirKu');
    }
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ── READ ─────────────────────────────────────────────────────────
  /// Baca CSV. Jika file belum ada → kembalikan list kosong []
  Future<List<ItemModel>> readAll() async {
    final f = await _file;
    if (!await f.exists()) return [];

    final lines = await f.readAsLines();
    final items = <ItemModel>[];

    for (final line in lines) {
      final t = line.trim();
      // Lewati baris kosong, komentar (#), dan header (id,name,...)
      if (t.isEmpty || t.startsWith('#') || t.startsWith('id,')) continue;
      try {
        items.add(ItemModel.fromCsvRow(t));
      } catch (_) {
        // Skip baris yang corrupt, lanjut ke baris berikutnya
      }
    }

    return items;
  }

  // ── WRITE (tulis ulang seluruh file) ────────────────────────────
  Future<void> writeAll(List<ItemModel> items) async {
    final f = await _file;
    final buf = StringBuffer();
    buf.writeln('# KasirKu Data | Terakhir diperbarui: ${DateTime.now()}');
    buf.writeln(ItemModel.csvHeader());
    for (final item in items) {
      buf.writeln(item.toCsvRow());
    }
    await f.writeAsString(buf.toString(), flush: true);
  }

  // ── TAMBAH ───────────────────────────────────────────────────────
  Future<List<ItemModel>> tambah(
    List<ItemModel> current,
    ItemModel baru,
  ) async {
    final maxId = current.isEmpty
        ? 0
        : current.map((i) => i.id).reduce((a, b) => a > b ? a : b);
    final withId = baru.copyWith(id: maxId + 1);
    final updated = [...current, withId];
    await writeAll(updated);
    return updated;
  }

  // ── UPDATE ───────────────────────────────────────────────────────
  Future<List<ItemModel>> update(
    List<ItemModel> current,
    ItemModel item,
  ) async {
    final updated = current.map((i) => i.id == item.id ? item : i).toList();
    await writeAll(updated);
    return updated;
  }

  // ── HAPUS ────────────────────────────────────────────────────────
  Future<List<ItemModel>> hapus(
    List<ItemModel> current,
    int id,
  ) async {
    final updated = current.where((i) => i.id != id).toList();
    await writeAll(updated);
    return updated;
  }

  Future<bool> fileExists() async {
    final f = await _file;
    return await f.exists();
  }
}
