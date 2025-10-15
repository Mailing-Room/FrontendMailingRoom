// lib/pages/dashboard/dashboard_selection.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../auth/login_page.dart';
import '../../models/user.dart';
import '../home_page.dart';

class DashboardSelectionPage extends StatelessWidget {
  const DashboardSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil instance AuthService dari Provider
    final authService = Provider.of<AuthService>(context, listen: false);

    // Gunakan StreamBuilder untuk mendengarkan status login secara real-time
    return StreamBuilder<MyUser?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        // 1. Saat sedang loading awal, tampilkan indikator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Jika sudah login (ada data user)
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          // Arahkan ke HomePage dengan parameter peran yang benar
          return HomePage(isKurir: user.role == 'kurir');
        }

        // 3. Jika belum login (tidak ada data), arahkan ke LoginPage
        return const LoginPage();
      },
    );
  }
}