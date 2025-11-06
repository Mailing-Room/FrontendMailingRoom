// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart';
import 'package:mailingroom/pages/dashboard/dashboard_selection_page.dart';
import 'package:mailingroom/pages/dashboard/kurir_dashboard.dart';
import 'package:provider/provider.dart';

// Import untuk format tanggal
import 'package:intl/date_symbol_data_local.dart';

// Import service dan provider
import 'package:mailingroom/auth/auth_service.dart';
import 'package:mailingroom/providers/surat_provider.dart';

void main() async { // Ubah jadi async
  // Pastikan Flutter siap
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal untuk 'id_ID' (Bahasa Indonesia)
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Definisikan warna tema
  static const Color posBlue = Color(0xFF00529C);
  static const Color posOrange = Color(0xFFF37021);
  static const Color lightGrey = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SuratProvider()),
      ],
      child: MaterialApp(
        title: 'Mailingroom POS IND',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: posBlue,
            primary: posBlue,
            secondary: posOrange,
            background: const Color(0xFFF8F9FA),
          ),
          
          textTheme: Theme.of(context).textTheme.merge(
            GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          ),

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
          
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: posOrange,
            foregroundColor: Colors.white,
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
            selectedItemColor: posOrange,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // PERBAIKAN: Menggunakan 'TabBarThemeData' dan properti 'indicator'
          tabBarTheme: TabBarThemeData(
            labelColor: posOrange,
            unselectedLabelColor: Colors.grey[600],
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: posOrange, width: 3),
            ),
          ),
          
          useMaterial3: true,
        ),

        home: KurirDashboard(user: MyUser(uid: '', email: '', role: '', nama: '')),
      ),
    );
  }
}