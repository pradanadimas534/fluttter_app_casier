import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/item_model.dart';

/// Simpan & baca data barang dari CSV lokal HP.
/// Setiap perubahan data → langsung tulis ulang file ini.
class CsvLocalService {
  static final CsvLocalService _i = CsvLocalService._();
  factory CsvLocalService() => _i;
  CsvLocalService._();

  static const _fileName = 'kasirku_data.csv';

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
      final base = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      dir = Directory('${base.path}/KasirKu');
    }
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ── READ ─────────────────────────────────────────────────────────
  Future<List<ItemModel>> readAll() async {
    final f = await _file;
    if (!await f.exists()) return [];

    final lines = await f.readAsLines();
    final items = <ItemModel>[];
    for (final line in lines) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('#') || t.startsWith('id,')) continue;
      try {
        items.add(ItemModel.fromCsvRow(t));
      } catch (_) {}
    }
    return items;
  }

  // ── WRITE ────────────────────────────────────────────────────────
  Future<void> writeAll(List<ItemModel> items) async {
    final f   = await _file;
    final buf = StringBuffer();
    buf.writeln('# KasirKu | uid: diisi provider | update: ${DateTime.now()}');
    buf.writeln(ItemModel.csvHeader());
    for (final item in items) {
      buf.writeln(item.toCsvRow());
    }
    await f.writeAsString(buf.toString(), flush: true);
  }

  // ── WRITE DARI STRING (hasil download Storage) ───────────────────
  Future<void> writeRaw(String csvContent) async {
    final f = await _file;
    await f.writeAsString(csvContent, flush: true);
  }

  // ── CEK ADA FILE LOKAL ───────────────────────────────────────────
  Future<bool> get hasLocalFile async => (await _file).exists();
}