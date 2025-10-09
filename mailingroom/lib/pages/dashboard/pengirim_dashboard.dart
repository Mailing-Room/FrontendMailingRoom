// Path: lib/pages/dashboard/pengirim_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/surat_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/surat_card.dart';
import '../../models/surat.dart';

class PengirimDashboard extends StatelessWidget {
  const PengirimDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuratProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Beranda'), backgroundColor: const Color(0xFF1E88E5)),
      body: StreamBuilder<List<Surat>>(
        stream: provider.allSuratStream,
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              const SectionHeader(title: 'Aksi Cepat'),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 12, children: [
                _actionCard(Icons.add, 'Tambah Surat', Colors.blue, () {}),
                _actionCard(Icons.inbox, 'Surat Masuk', Colors.deepPurple, () {}),
                _actionCard(Icons.send, 'Surat Keluar', Colors.orange, () {}),
                _actionCard(Icons.visibility, 'Lacak Surat', Colors.green, () {}),
              ]),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Statistik'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statCard('Surat Masuk', list.where((s) => s.jenisSurat == 'Masuk').length, Icons.inbox, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Surat Keluar', list.where((s) => s.jenisSurat == 'Keluar').length, Icons.send, Colors.orange)),
              ]),
              const SizedBox(height: 18),
              const SectionHeader(title: '📂 Semua Surat', actionLabel: 'Lihat Semua', onAction: null),
              const SizedBox(height: 8),
              Column(children: list.map((s) => SuratCard(surat: s)).toList()),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 160,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 2, padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text('', style: const TextStyle(fontSize: 12, color: Colors.black54))])),
        ]),
      ),
    );
  }

  Widget _statCard(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 4), Text(title, style: const TextStyle(color: Colors.black54))]),
        ]),
      ),
    );
  }
}
