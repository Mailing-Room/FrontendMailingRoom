// Path: lib/pages/surat_rangkuman_page.dart
import 'package:flutter/material.dart';
import 'package:mailingroom/services/database_service.dart';
import 'package:mailingroom/widgets/surat_card.dart';
import '../models/surat.dart';

class SuratRangkumanPage extends StatefulWidget {
  const SuratRangkumanPage({super.key});

  @override
  State<SuratRangkumanPage> createState() => _SuratRangkumanPageState();
}

class _SuratRangkumanPageState extends State<SuratRangkumanPage> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: StreamBuilder<List<Surat>>(
          stream: _db.getSuratList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data surat.'));
            }

            final allSurat = snapshot.data!;

            // ✅ LOGIKA FILTER DIPERBARUI DI SINI
            // Surat Masuk = Semua surat yang statusnya BUKAN 'terkirim'
            final suratMasuk = allSurat.where((s) => s.status.toLowerCase() != 'terkirim').toList();
            
            // Surat Keluar = Semua surat yang statusnya ADALAH 'terkirim'
            final suratKeluar = allSurat.where((s) => s.status.toLowerCase() == 'terkirim').toList();

            return Column(
              children: [
                const TabBar(
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: [
                    Tab(text: 'Surat Masuk'),
                    Tab(text: 'Surat Keluar'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSuratList(suratMasuk),
                      _buildSuratList(suratKeluar),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuratList(List<Surat> suratList) {
    if (suratList.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada surat di kategori ini.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suratList.length,
      itemBuilder: (context, index) {
        final surat = suratList[index];
        return SuratCard(surat: surat);
      },
    );
  }
}