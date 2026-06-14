import 'package:flutter/material.dart';
import 'package:fluttter_app_casier/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'providers/kasir_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => KasirProvider()..init(), // ← tambah ..init()
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const _AppLoader(), // ← pakai loader dulu
    );
  }
}

// Tunggu init() selesai baru tampilkan HomeScreen
// Ini mencegah layar kosong saat CSV sedang dibaca
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KasirProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 12),
              Text(
                'Memuat data...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}