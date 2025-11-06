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
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        
        if (authService.isCheckingLogin) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authService.currentUser != null) {
          final user = authService.currentUser!;
          
          switch (user.role) {
            case 'admin':
              return const AdminDashboard();
            
            // ✅ PERBAIKAN: Kirim seluruh object 'user' ke HomePage
            case 'kurir':
            case 'pengirim':
            case 'penerima':
              return HomePage(user: user); 
              
            default:
              return const LoginPage();
          }
        }
        
        return const LoginPage();
      },
    );
  }
}