// Path: lib/pages/surat_rangkuman_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Impor package animasi
import 'package:mailingroom/services/database_service.dart';
import 'package:mailingroom/widgets/surat_card.dart';
import '../models/surat.dart';

class SuratRangkumanPage extends StatefulWidget {
  final int initialTabIndex;
  const SuratRangkumanPage({super.key, this.initialTabIndex = 0});

  @override
  State<SuratRangkumanPage> createState() => _SuratRangkumanPageState();
}

class _SuratRangkumanPageState extends State<SuratRangkumanPage> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 2,
      child: Scaffold(
        body: StreamBuilder<List<Surat>>(
          stream: _db.getSuratList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(); // Tampilan kosong yang lebih baik
            }

            final allSurat = snapshot.data!;
            final suratMasuk = allSurat.where((s) => s.status.toLowerCase() != 'terkirim').toList();
            final suratKeluar = allSurat.where((s) => s.status.toLowerCase() == 'terkirim').toList();

            return Column(
              children: [
                const TabBar(
                  labelColor: Color(0xFF00529C), // Warna Pos Indonesia
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF00529C),
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

  // Widget untuk tampilan saat tidak ada data
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Surat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua data surat akan muncul di sini.',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun daftar surat dengan fitur interaktif
  Widget _buildSuratList(List<Surat> suratList) {
    if (suratList.isEmpty) {
      return _buildEmptyState(); // Gunakan tampilan kosong yang baru
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Aksi saat ditarik untuk refresh.
        // Karena kita pakai StreamBuilder, data akan otomatis update.
        // Kita hanya perlu menunggu sejenak untuk menampilkan indikator.
        await Future.delayed(const Duration(seconds: 1));
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suratList.length,
          itemBuilder: (context, index) {
            final surat = suratList[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: SuratCard(surat: surat),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}