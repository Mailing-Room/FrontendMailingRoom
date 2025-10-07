// Path: lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:mailingroom/models/user.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import 'dashboard/pengirim_dashboard.dart';
import 'dashboard/kurir_dashboard.dart';
import 'dashboard/peneriman_dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat Datang, ${user.email}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
      body: _buildDashboard(context, user),
    );
  }

  Widget _buildDashboard(BuildContext context, MyUser user) {
    switch (user.role) {
      case 'pengirim':
        return const PengirimDashboard();
      case 'kurir':
        return const KurirDashboard();
      case 'penerima':
        return const PenerimaDashboard();
      default:
        return const Center(child: Text('Peran pengguna tidak dikenali.'));
    }
  }
}