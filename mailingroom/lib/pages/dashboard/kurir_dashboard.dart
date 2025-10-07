// Path: lib/pages/dashboards/kurir_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/services/database_service.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/models/user.dart';

class KurirDashboard extends StatelessWidget {
  const KurirDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil user dari Provider untuk mendapatkan email kurir
    final MyUser? user = Provider.of<MyUser?>(context);

    if (user == null) {
      return const Center(child: Text('User tidak ditemukan.'));
    }

    return StreamBuilder<List<Surat>>(
      // Mengambil data surat yang statusnya 'Menunggu Kurir' atau 'Dalam Pengiriman'
      stream: DatabaseService().getKurirSurat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
        }

        final List<Surat> suratList = snapshot.data ?? [];

        if (suratList.isEmpty) {
          return const Center(child: Text('Tidak ada surat yang perlu diantar saat ini.'));
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tugas Anda',
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
                        title: Text(surat.perihal),
                        subtitle: Text('Status: ${surat.status}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Logika untuk mengubah status surat
                            final newStatus = (surat.status == 'Menunggu Kurir')
                                ? 'Dalam Pengiriman'
                                : 'Terkirim';
                            DatabaseService().updateSuratStatus(surat.id!, newStatus);
                          },
                          child: Text(
                            (surat.status == 'Menunggu Kurir')
                                ? 'Ambil Surat'
                                : 'Selesaikan',
                          ),
                        ),
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
}