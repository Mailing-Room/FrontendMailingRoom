// Path: lib/pages/notifikasi_page.dart
import 'package:flutter/material.dart';
// Anda mungkin perlu mengimpor model Notifikasi jika sudah ada
// import '../models/notifikasi.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // Data notifikasi contoh
  final List<Map<String, dynamic>> _daftarNotifikasi = [
    {
      'id': '1', 'judul': 'Status Diperbarui', 'pesan': 'Surat No. 123/PKS/X/2025 telah sampai.', 'tipe': 'selesai', 'sudahDibaca': false,
    },
    {
      'id': '2', 'judul': 'Surat Masuk Baru', 'pesan': 'Anda menerima surat baru dari Divisi HRD.', 'tipe': 'surat_masuk', 'sudahDibaca': false,
    },
    {
      'id': '3', 'judul': 'Pengiriman Diproses', 'pesan': 'Surat Edaran Libur Nasional sedang dikirim.', 'tipe': 'pengiriman', 'sudahDibaca': true,
    },
  ];

  IconData _getIconForType(String tipe) {
    // ... (fungsi helper ikon)
    return Icons.notifications_outlined;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Notifikasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _daftarNotifikasi.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _daftarNotifikasi.length,
              itemBuilder: (context, index) {
                final notifikasi = _daftarNotifikasi[index];
                return Dismissible(
                  key: Key(notifikasi['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _daftarNotifikasi.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notifikasi['sudahDibaca'] ? Colors.grey[200] : Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(_getIconForType(notifikasi['tipe']), color: notifikasi['sudahDibaca'] ? Colors.grey : Theme.of(context).primaryColor),
                    ),
                    title: Text(
                      notifikasi['judul'],
                      style: TextStyle(fontWeight: notifikasi['sudahDibaca'] ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text(notifikasi['pesan']),
                    onTap: () {
                      setState(() {
                        notifikasi['sudahDibaca'] = true;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}