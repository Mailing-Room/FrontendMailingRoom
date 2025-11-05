// lib/pages/dashboard/dashboard_selection.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../auth/login_page.dart';
import '../../models/user.dart';
import '../home_page.dart';
import 'admin_dashboard.dart';

class DashboardSelectionPage extends StatelessWidget {
  const DashboardSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Kode ini akan mendengarkan status login
    return StreamBuilder<MyUser?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        
        // 1. Saat 'AuthService' sedang mengecek token (jika ada)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Jika 'AuthService' mengirim data user (artinya login berhasil)
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          switch (user.role) {
            case 'admin':
              return const AdminDashboard();
            case 'kurir':
              return const HomePage(role: 'kurir');
            case 'pengirim':
              return const HomePage(role: 'pengirim');
            case 'penerima':
              return const HomePage(role: 'penerima');
            default:
              return const LoginPage();
          }
        }
        
        // 3. Jika 'AuthService' mengirim 'null' (artinya belum login)
        return const LoginPage();
      },
    );
  }
}