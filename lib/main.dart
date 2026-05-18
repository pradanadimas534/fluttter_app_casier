import 'package:flutter/material.dart';
import 'package:fluttter_app_casier/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'providers/kasir_provider.dart';
// import 'screens/kasir_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => KasirProvider(),
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
      home: const HomeScreen(),
    );
  }
}