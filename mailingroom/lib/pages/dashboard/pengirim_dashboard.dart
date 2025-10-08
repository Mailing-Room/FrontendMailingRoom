// Path: lib/pages/dashboards/pengirim_dashboard.dart

import 'package:flutter/material.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import 'package:mailingroom/pages/detail_surat.dart';
import 'package:mailingroom/services/database_service.dart';

class PengirimDashboard extends StatelessWidget {
  PengirimDashboard({super.key});

  final List<Surat> _dummySuratList = [
    Surat(
      id: '1',
      nomor: '123/PKS/X/2025',
      perihal: 'Perjanjian Kerja Sama Proyek A',
      deskripsiSurat: 'Dokumen perjanjian kerja sama proyek',
      sifatSurat: 'Penting',
      fileSuratUrl: null,
      lpSuratUrl: null,
      berat: 100.0,
      pengirimAsal: 'PT Sentosa Abadi',
      pengirimDivisi: 'Marketing',
      pengirimDepartemen: 'Sales',
      penerimaTujuan: 'penerima@mailingroom.com',
      penerimaDivisi: 'Keuangan',
      penerimaDepartemen: 'Accounting',
      jenisSurat: 'Masuk',
      status: 'Menunggu Kurir',
      tanggal: '2025-10-08',
    ),
    Surat(
      id: '2',
      nomor: '321/ED/X/2025',
      perihal: 'Surat Edaran Libur Nasional',
      deskripsiSurat: 'Surat edaran resmi mengenai libur nasional',
      sifatSurat: 'Biasa',
      fileSuratUrl: null,
      lpSuratUrl: null,
      berat: 50.0,
      pengirimAsal: 'Divisi HRD',
      pengirimDivisi: 'HR',
      pengirimDepartemen: 'General Affairs',
      penerimaTujuan: 'penerima@mailingroom.com',
      penerimaDivisi: 'Semua',
      penerimaDepartemen: 'Semua',
      jenisSurat: 'Keluar',
      status: 'Terkirim',
      tanggal: '2025-10-07',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Karena tidak menggunakan StreamBuilder, kita bisa langsung menggunakan data dummy
    final int totalMasuk = _dummySuratList.where((s) => s.jenisSurat == 'Masuk').length;
    final int totalKeluar = _dummySuratList.where((s) => s.jenisSurat == 'Keluar').length;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCards(totalMasuk, totalKeluar),
            const SizedBox(height: 20),
            const Text(
              'Semua Surat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _dummySuratList.length,
                itemBuilder: (context, index) {
                  final surat = _dummySuratList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(surat.perihal),
                      subtitle: Text('No. ${surat.nomor} | Status: ${surat.status}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SuratDetailPage(surat: surat)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditSuratPage()),
          );
        },
        backgroundColor: Colors.green, // Ganti warna latar belakang
        tooltip: 'Tambah Surat Baru', // Tambahkan tooltip
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCards(int totalMasuk, int totalKeluar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard('Masuk', totalMasuk, Icons.arrow_downward, Colors.blue),
        _buildStatCard('Keluar', totalKeluar, Icons.arrow_upward, Colors.orange),
      ],
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}