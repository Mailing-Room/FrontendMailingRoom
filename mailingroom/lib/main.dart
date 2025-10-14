// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// 1. Sesuaikan path import ini dengan struktur folder Anda
import 'package:mailingroom/pages/home_page.dart'; 
import 'package:mailingroom/providers/surat_provider.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Definisikan warna tema di sini agar mudah diakses
  static const Color posBlue = Color(0xFF00529C);
  static const Color posOrange = Color(0xFFF37021);
  static const Color lightGrey = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    // Menggunakan MultiProvider untuk menyiapkan state management di seluruh aplikasi
    return MultiProvider(
      providers: [
        // 2. Mendaftarkan SuratProvider Anda di sini
        ChangeNotifierProvider(create: (_) => SuratProvider()),

        // Anda bisa menambahkan provider lain di bawahnya jika ada
      ],
      child: MaterialApp(
        title: 'Mailingroom POS IND',
        debugShowCheckedModeBanner: false,

        // ======================================================= //
        // ==     TEMA GLOBAL UNTUK NUANSA PT POS INDONESIA     == //
        // ======================================================= //
        theme: ThemeData(
          // 1. Skema Warna Utama
          colorScheme: ColorScheme.fromSeed(
            seedColor: posBlue,
            primary: posBlue,
            secondary: posOrange,
            background: const Color(0xFFF8F9FA),
          ),
          
          // 2. Terapkan Font Default ke Seluruh Aplikasi
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),

          // 3. Kustomisasi Gaya Widget Default
          appBarTheme: AppBarTheme(
            backgroundColor: posBlue,
            foregroundColor: Colors.white,
            elevation: 1.0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: posOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: posOrange, width: 2),
            ),
            labelStyle: TextStyle(color: posBlue.withOpacity(0.8)),
          ),
          
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: posBlue,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          useMaterial3: true,
        ),

        // Halaman pertama yang akan dibuka
        home: const HomePage(),
      ),
    );
  }
}