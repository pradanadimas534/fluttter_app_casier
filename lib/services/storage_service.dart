import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Upload & download file CSV ke Firebase Storage.
/// Path di Storage: users/{uid}/kasirku_data.csv
/// → per akun, tidak bisa diakses akun lain
class StorageService {
  static final StorageService _i = StorageService._();
  factory StorageService() => _i;
  StorageService._();

  static const _prefLastBackup = 'last_backup_time';
  final _storage = FirebaseStorage.instance;

  Reference _ref(String uid) =>
      _storage.ref().child('users/$uid/kasirku_data.csv');

  // ── UPLOAD (backup ke cloud) ─────────────────────────────────────
  Future<BackupResult> upload(String uid, String localFilePath) async {
    try {
      final file = File(localFilePath);
      if (!await file.exists()) return BackupResult.fileTidakAda;

      await _ref(uid).putFile(
        file,
        SettableMetadata(
          contentType: 'text/csv',
          customMetadata: {
            'uid':       uid,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Catat waktu backup terakhir
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastBackup, DateTime.now().toIso8601String());

      return BackupResult.sukses;
    } on FirebaseException catch (e) {
      if (e.code == 'network-request-failed') return BackupResult.offline;
      return BackupResult.gagal;
    } catch (_) {
      return BackupResult.gagal;
    }
  }

  // ── DOWNLOAD (restore dari cloud) ────────────────────────────────
  /// Kembalikan isi CSV sebagai String, atau null jika tidak ada / error
  Future<String?> download(String uid) async {
    try {
      final bytes = await _ref(uid).getData(10 * 1024 * 1024); // max 10MB
      if (bytes == null) return null;
      return String.fromCharCodes(bytes);
    } on FirebaseException catch (e) {
      // object-not-found = belum pernah backup → wajar, bukan error
      if (e.code == 'object-not-found') return null;
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── CEK ADA BACKUP DI CLOUD ──────────────────────────────────────
  Future<bool> hasCloudBackup(String uid) async {
    try {
      await _ref(uid).getMetadata();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── WAKTU BACKUP TERAKHIR ────────────────────────────────────────
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_prefLastBackup);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // ── PERLU BACKUP? (sudah lebih dari 24 jam) ──────────────────────
  Future<bool> get needsBackup async {
    final last = await getLastBackupTime();
    if (last == null) return true;
    return DateTime.now().difference(last).inHours >= 24;
  }
}

enum BackupResult { sukses, offline, fileTidakAda, gagal }