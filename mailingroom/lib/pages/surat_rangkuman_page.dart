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
  
  // Controller untuk Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Warna khas
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);

  @override
  void initState() {
    super.initState();
    // Listener untuk search real-time
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. BUNGKUS SCAFFOLD DENGAN DefaultTabController
    return DefaultTabController(
      // Key ini PENTING: Memaksa controller dibuat ulang jika initialTabIndex berubah
      key: ValueKey(widget.initialTabIndex), 
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // 2. HEADER CUSTOM (Search & Tabs)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nomor, perihal, atau pengirim...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  // Tab Bar (Tanpa controller manual)
                  TabBar(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    labelColor: posBlue,
                    unselectedLabelColor: Colors.grey[500],
                    indicatorColor: posOrange,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inbox_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Surat Masuk'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.outbox_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Surat Keluar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. KONTEN LIST (StreamBuilder)
            Expanded(
              child: StreamBuilder<List<Surat>>(
                stream: _db.getSuratList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: posOrange));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState('Belum Ada Surat', 'Data surat akan muncul di sini.');
                  }

                  final allSurat = snapshot.data!;
                  
                  // Filter Masuk & Keluar + Search Query
                  final suratMasuk = allSurat.where((s) => 
                      s.jenisSurat.toLowerCase().contains('masuk') && 
                      _matchesSearch(s)
                  ).toList();
                  
                  final suratKeluar = allSurat.where((s) => 
                      s.jenisSurat.toLowerCase().contains('keluar') && 
                      _matchesSearch(s)
                  ).toList();

                  // TabBarView (Tanpa controller manual)
                  return TabBarView(
                    children: [
                      _buildSuratList(suratMasuk, 'Kotak Masuk Kosong'),
                      _buildSuratList(suratKeluar, 'Kotak Keluar Kosong'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Logika Search Sederhana
  bool _matchesSearch(Surat s) {
    if (_searchQuery.isEmpty) return true;
    return s.nomor.toLowerCase().contains(_searchQuery) ||
           s.perihal.toLowerCase().contains(_searchQuery) ||
           s.pengirimAsal.toLowerCase().contains(_searchQuery) ||
           (s.penerimaTujuan ?? '').toLowerCase().contains(_searchQuery);
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuratList(List<Surat> suratList, String emptyMessage) {
    if (suratList.isEmpty) {
      // Tampilkan empty state khusus jika hasil search tidak ada
      if (_searchQuery.isNotEmpty) {
        return _buildEmptyState('Tidak Ditemukan', 'Tidak ada surat yang cocok dengan pencarian "$_searchQuery"');
      }
      return _buildEmptyState(emptyMessage, 'Belum ada data surat di kategori ini.');
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulasi refresh, karena Stream sudah auto-update
        await Future.delayed(const Duration(seconds: 1));
      },
      color: posOrange,
      backgroundColor: Colors.white,
      child: AnimationLimiter(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Padding bawah extra untuk FAB/Navbar
          itemCount: suratList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final surat = suratList[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  // Menggunakan SuratCard yang sudah ada
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