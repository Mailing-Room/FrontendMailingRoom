import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'auth/auth_service.dart';
import 'auth/demo_auth_service.dart';
import 'auth/demo_login_page.dart';
import 'pages/home_page.dart';
import 'pages/onboarding_page.dart';
import 'providers/surat_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(
    'id_ID',
    null,
  );

  runApp(const MailingRoomDemoApp());
}

class MailingRoomDemoApp
    extends StatelessWidget {
  const MailingRoomDemoApp({super.key});

  static const Color posBlue =
      Color(0xFF00529C);

  static const Color posOrange =
      Color(0xFFF37021);

  static const Color lightGrey =
      Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // PENTING:
        // DemoAuthService diberikan sebagai AuthService
        // supaya HomePage / ProfilPage asli tetap
        // menemukan Provider<AuthService>.
        ChangeNotifierProvider<AuthService>(
          create: (_) => DemoAuthService(),
        ),

        ChangeNotifierProvider(
          create: (_) => SuratProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mailingroom Demo',

        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(
            seedColor: posBlue,
            primary: posBlue,
            secondary: posOrange,
            background:
                const Color(0xFFF8F9FA),
          ),

          textTheme:
              GoogleFonts.poppinsTextTheme(),

          appBarTheme: AppBarTheme(
            backgroundColor: posBlue,
            foregroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            titleTextStyle:
                GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          elevatedButtonTheme:
              ElevatedButtonThemeData(
            style:
                ElevatedButton.styleFrom(
              backgroundColor: posOrange,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 24,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
              textStyle:
                  GoogleFonts.poppins(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          inputDecorationTheme:
              InputDecorationTheme(
            filled: true,
            fillColor: lightGrey,
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  BorderSide.none,
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide:
                  const BorderSide(
                color: posOrange,
                width: 2,
              ),
            ),
            labelStyle: TextStyle(
              color:
                  posBlue.withOpacity(0.8),
            ),
          ),

          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData(
            selectedItemColor:
                posOrange,
            unselectedItemColor:
                Colors.grey,
          ),

          useMaterial3: true,
        ),

        home: Builder(
          builder: (context) {
            return OnboardingPage(
              onOnboardingComplete: () {
                Navigator.of(context)
                    .pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        const DemoAuthGate(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


// ======================================================
// AUTH GATE
// ======================================================
//
// Tugasnya:
// currentUser == null
//       ↓
// Login
//
// currentUser != null
//       ↓
// Dashboard
//
// Saat logout:
// currentUser menjadi null
//       ↓
// otomatis kembali Login
//

class DemoAuthGate
    extends StatelessWidget {
  const DemoAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (
        context,
        authService,
        child,
      ) {
        if (authService.isCheckingLogin) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        final user =
            authService.currentUser;

        if (user == null) {
          return const DemoLoginPage();
        }

        return HomePage(
          user: user,
        );
      },
    );
  }
}