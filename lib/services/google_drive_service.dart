import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Upload file CSV ke Google Drive menggunakan akun Google pengguna.
/// Tidak perlu Google Cloud Console berbayar — cukup OAuth2 personal.
class GoogleDriveService {
  static final GoogleDriveService _i = GoogleDriveService._();
  factory GoogleDriveService() => _i;
  GoogleDriveService._();

  static const _prefKeyLastUpload = 'last_drive_upload';
  static const _prefKeyFileId     = 'drive_file_id'; // ID file di Drive agar tidak duplikat

  // Scope minimal: hanya bisa baca/tulis file yang dibuat app ini sendiri
  final _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  GoogleSignInAccount? _account;
  bool get isSignedIn => _account != null;
  String? get userEmail => _account?.email;

  // ── LOGIN ────────────────────────────────────────────────────────
  Future<bool> signIn(BuildContext context) async {
    try {
      _account = await _googleSignIn.signIn();
      return _account != null;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _account = null;
  }

  /// Login diam-diam (pakai akun yang sudah pernah login, tanpa popup)
  Future<bool> signInSilently() async {
    _account = await _googleSignIn.signInSilently();
    return _account != null;
  }

  // ── JADWAL UPLOAD ────────────────────────────────────────────────
  Future<DateTime?> getLastUploadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyLastUpload);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> _setLastUploadTime(DateTime t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyLastUpload, t.toIso8601String());
  }

  /// Cek apakah sudah 24 jam sejak upload terakhir.
  /// Dipanggil saat app dibuka / setelah ada perubahan data.
  Future<void> cekDanUpload(String csvFilePath) async {
    // Pastikan sudah login diam-diam dulu
    final ok = await signInSilently();
    if (!ok) return; // Belum login → skip, tidak error

    final last = await getLastUploadTime();
    final now = DateTime.now();
    final perlu = last == null || now.difference(last).inHours >= 24;
    if (!perlu) return;

    await uploadFile(csvFilePath);
  }

  // ── UPLOAD FILE ──────────────────────────────────────────────────
  Future<UploadResult> uploadFile(String csvFilePath) async {
    if (_account == null) {
      final ok = await signInSilently();
      if (!ok) return UploadResult.belumLogin;
    }

    try {
      final auth = await _account!.authHeaders;
      final file = File(csvFilePath);
      if (!await file.exists()) return UploadResult.fileTidakAda;

      final bytes = await file.readAsBytes();
      final prefs = await SharedPreferences.getInstance();
      final existingFileId = prefs.getString(_prefKeyFileId);

      String fileId;

      if (existingFileId != null) {
        // ── UPDATE file yang sudah ada (tidak duplikat) ──
        final resp = await http.patch(
          Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files/$existingFileId?uploadType=media',
          ),
          headers: {
            ...auth,
            'Content-Type': 'text/csv',
          },
          body: bytes,
        );
        if (resp.statusCode == 200 || resp.statusCode == 204) {
          fileId = existingFileId;
        } else {
          // File mungkin terhapus dari Drive → buat baru
          fileId = await _createNewFile(auth, bytes);
        }
      } else {
        // ── BUAT file baru pertama kali ──
        fileId = await _createNewFile(auth, bytes);
      }

      await prefs.setString(_prefKeyFileId, fileId);
      await _setLastUploadTime(DateTime.now());
      return UploadResult.sukses;
    } catch (e) {
      debugPrint('Drive upload error: $e');
      return UploadResult.gagal;
    }
  }

  Future<String> _createNewFile(
    Map<String, String> auth,
    List<int> bytes,
  ) async {
    // Step 1: buat metadata
    final metaResp = await http.post(
      Uri.parse('https://www.googleapis.com/drive/v3/files'),
      headers: {
        ...auth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': 'kasirku_data.csv',
        'mimeType': 'text/csv',
        // Simpan di folder root Drive (bisa diubah ke folder spesifik)
      }),
    );

    final metaJson = jsonDecode(metaResp.body) as Map<String, dynamic>;
    final newId = metaJson['id'] as String;

    // Step 2: upload isi file
    await http.patch(
      Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files/$newId?uploadType=media',
      ),
      headers: {
        ...auth,
        'Content-Type': 'text/csv',
      },
      body: bytes,
    );

    return newId;
  }
}

enum UploadResult { sukses, belumLogin, fileTidakAda, gagal }
