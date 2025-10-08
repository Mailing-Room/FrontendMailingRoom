// Path: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'auth/login_page.dart';
import 'models/user.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  // Komentar atau hapus baris inisialisasi Firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Alih-alih StreamProvider, kita menggunakan Provider biasa
    return Provider<MyUser?>(
      create: (_) => MyUser(uid: 'dummy_id', email: 'pengirim@example.com', role: 'pengirim'),
      child: MaterialApp(
        title: 'Mailingroom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(), // Langsung ke HomePage
      ),
    );
  }
}

// Hapus atau abaikan widget AuthWrapper