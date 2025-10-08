// Path: lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'dashboard/pengirim_dashboard.dart';
import 'dashboard/kurir_dashboard.dart';
import 'dashboard/peneriman_dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user dari Provider
    final MyUser? user = Provider.of<MyUser?>(context);

    // Tampilan ini akan selalu dijalankan karena user sudah disalurkan
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${user.role.toUpperCase()}'),
        // Hapus tombol logout jika Anda tidak ingin mengujinya
      ),
      body: _buildDashboard(context, user),
    );
  }

  Widget _buildDashboard(BuildContext context, MyUser user) {
    // Tampilkan dashboard yang sesuai dengan peran pengguna
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