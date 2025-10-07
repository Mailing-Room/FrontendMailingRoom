// Path: lib/pages/dashboards/pengirim_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/services/database_service.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/models/user.dart';

class PengirimDashboard extends StatelessWidget {
  const PengirimDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Surat>>(
      stream: DatabaseService().getSuratList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Belum ada data surat yang dicatat.'));
        }

        final List<Surat> suratList = snapshot.data!;
        
        // Menghitung statistik
        final int totalSuratMasuk = suratList.where((s) => s.jenisSurat == 'Masuk').length;
        final int totalSuratKeluar = suratList.where((s) => s.jenisSurat == 'Keluar').length;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ringkasan Surat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Surat Masuk', totalSuratMasuk, Icons.inbox, Colors.blue),
                  _buildStatCard('Surat Keluar', totalSuratKeluar, Icons.outbox, Colors.orange),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Daftar Surat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: suratList.length,
                  itemBuilder: (context, index) {
                    final surat = suratList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: surat.jenisSurat == 'Masuk' ? Colors.blue : Colors.orange,
                          child: Icon(
                            surat.jenisSurat == 'Masuk' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(surat.perihal),
                        subtitle: Text('No: ${surat.nomor} | Status: ${surat.status}'),
                        onTap: () {
                          // TODO: Navigasi ke halaman detail surat
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 150,
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}