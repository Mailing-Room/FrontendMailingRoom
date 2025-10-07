// Path: lib/pages/dashboards/penerima_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/services/database_service.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/models/user.dart';

class PenerimaDashboard extends StatelessWidget {
  const PenerimaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil user dari Provider untuk mendapatkan email penerima
    final MyUser? user = Provider.of<MyUser?>(context);

    if (user == null) {
      return const Center(child: Text('User tidak ditemukan.'));
    }

    return StreamBuilder<List<Surat>>(
      // Mengambil data surat yang penerimanya adalah email user saat ini
      stream: DatabaseService().getSuratByPenerima(user.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
        }

        final List<Surat> suratList = snapshot.data ?? [];

        if (suratList.isEmpty) {
          return const Center(child: Text('Tidak ada surat yang ditujukan untuk Anda saat ini.'));
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kotak Masuk Anda',
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
                          backgroundColor: Colors.green,
                          child: Icon(Icons.mark_email_read, color: Colors.white),
                        ),
                        title: Text(surat.perihal),
                        subtitle: Text('Pengirim: ${surat.pengirimAsal} | Status: ${surat.status}'),
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