import 'package:flutter/material.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import 'package:mailingroom/pages/detail_surat.dart';

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
    final int totalMasuk = _dummySuratList.where((s) => s.jenisSurat == 'Masuk').length;
    final int totalKeluar = _dummySuratList.where((s) => s.jenisSurat == 'Keluar').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
      appBar: AppBar(
        title: const Text('Dashboard User'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistik Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Masuk', totalMasuk, Icons.mail_outline, Colors.blueAccent),
                _buildStatCard('Keluar', totalKeluar, Icons.send_outlined, Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '📂 Semua Surat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _dummySuratList.length,
                itemBuilder: (context, index) {
                  final surat = _dummySuratList[index];
                  return _buildSuratCard(context, surat);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditSuratPage()),
          );
        },
        label: const Text('Tambah Surat'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple.shade400,
      ),
    );
  }

  // Statistik Card
  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Surat
  Widget _buildSuratCard(BuildContext context, Surat surat) {
    Color statusColor;
    if (surat.status == 'Terkirim') {
      statusColor = const Color.fromARGB(255, 20, 91, 23);
    } else if (surat.status == 'Menunggu Kurir') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          surat.perihal,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('No. ${surat.nomor}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  surat.status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuratDetailPage(surat: surat)),
          );
        },
      ),
    );
  }
}
