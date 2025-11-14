import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import package
import '../../auth/auth_service.dart';
import '../../auth/login_page.dart';
import '../../models/user.dart';
import '../home_page.dart';
import 'admin_dashboard.dart';
import '../onboarding_page.dart'; // Import halaman onboarding

class DashboardSelectionPage extends StatefulWidget {
  const DashboardSelectionPage({super.key});

  @override
  State<DashboardSelectionPage> createState() => _DashboardSelectionPageState();
}

class _DashboardSelectionPageState extends State<DashboardSelectionPage> {
  // Kita gunakan FutureBuilder untuk menangani pengecekan SharedPreferences
  late Future<bool> _checkOnboardingFuture;

  @override
  void initState() {
    super.initState();
    _checkOnboardingFuture = _checkOnboardingStatus();
  }

  // Fungsi untuk mengecek status onboarding (hanya dijalankan sekali)
  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingComplete') ?? false;
  }

  // Fungsi untuk menandai onboarding selesai
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    setState(() {
      // Set ulang future agar UI membangun ulang ke alur login
      _checkOnboardingFuture = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingFuture,
      builder: (context, snapshot) {
        // 1. Saat sedang mengecek SharedPreferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final bool hasCompletedOnboarding = snapshot.data ?? false;

        // 2. Jika BELUM onboarding, tampilkan OnboardingPage
        if (!hasCompletedOnboarding) {
          return OnboardingPage(onOnboardingComplete: _completeOnboarding);
        }

        // 3. Jika SUDAH onboarding, jalankan alur autentikasi
        return Consumer<AuthService>(
          builder: (context, authService, child) {
            // Saat AuthService sedang mengecek (misal: token)
            if (authService.isCheckingLogin) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            // Saat sudah login
            if (authService.currentUser != null) {
              final user = authService.currentUser!;

              String userRole = user.role;
              // -------------------------

              switch (userRole) {
                case 'admin':
                  return const AdminDashboard();

                // Menambahkan case untuk 'user' yang dikirim backend
                case 'user':
                  return HomePage(user: user);

                case 'kurir':
                  return HomePage(user: user);
                case 'pengirim': // Dibiarkan jika ada user lama
                  return HomePage(user: user);
                case 'penerima': // Dibiarkan jika ada user lama
                  return HomePage(user: user);

                default:
                  // Jika role tidak dikenali, logout dan kembali ke login
                  authService.signOut();
                  return const LoginPage();
              }
            }

            // Saat belum login
            return const LoginPage();
          },
        );
      },
    );
  }
}
