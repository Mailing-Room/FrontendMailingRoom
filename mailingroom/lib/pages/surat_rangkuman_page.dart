// lib/pages/surat_rangkuman_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Warna khas Pos Indonesia
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        // Menggunakan AppBar standar, bukan NestedScrollView
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false, // Menghilangkan tombol back
          elevation: 1.0, // Sedikit bayangan
          // Menempatkan TabBar di dalam bottom AppBar
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            labelColor: Colors.white,
            unselectedLabelColor: posBlue,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: posBlue,
              borderRadius: BorderRadius.circular(50),
            ),
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            tabs: [
              _buildTab('Surat Masuk', Icons.inbox_outlined),
              _buildTab('Surat Keluar', Icons.send_outlined),
            ],
          ),
        ),
        body: StreamBuilder<List<Surat>>(
          stream: _db.getSuratList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: posOrange));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState('Belum Ada Surat', 'Semua data surat akan muncul di sini saat Anda membuatnya.');
            }

            final allSurat = snapshot.data!;
            final suratMasuk = allSurat.where((s) => s.jenisSurat.toLowerCase() == 'masuk').toList();
            final suratKeluar = allSurat.where((s) => s.jenisSurat.toLowerCase() == 'keluar').toList();

            // Langsung menampilkan TabBarView di body
            return TabBarView(
              children: [
                _buildSuratList(suratMasuk),
                _buildSuratList(suratKeluar),
              ],
            );
          },
        ),
      ),
    );
  }

  Tab _buildTab(String title, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/pos_empty_box.png', height: 150, errorBuilder: (c, e, s) => Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.grey[300])),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: posBlue),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuratList(List<Surat> suratList) {
    if (suratList.isEmpty) {
      return _buildEmptyState('Belum Ada Surat', 'Data untuk kategori ini akan muncul di sini.');
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      color: posOrange,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: suratList.length,
          itemBuilder: (context, index) {
            final surat = suratList[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SuratCard(surat: surat),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}