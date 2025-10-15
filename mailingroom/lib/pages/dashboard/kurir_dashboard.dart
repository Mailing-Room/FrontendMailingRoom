// lib/pages/dashboard/kurir_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/surat.dart';
import '../../providers/surat_provider.dart';
import '../../widgets/surat_card.dart';

class KurirDashboard extends StatefulWidget {
  const KurirDashboard({super.key});

  @override
  State<KurirDashboard> createState() => _KurirDashboardState();
}

class _KurirDashboardState extends State<KurirDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);
  final Color lightOrangeBg = const Color(0xFFFFF7F2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuratProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: lightOrangeBg,
      body: StreamBuilder<List<Surat>>(
        stream: provider.kurirSuratStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: posOrange));
          }

          final allSurat = snapshot.data ?? [];
          
          final stats = {
            'menunggu': allSurat.where((s) => s.status == 'Menunggu Kurir').length,
            'proses': allSurat.where((s) => s.status == 'Dalam Proses').length,
            'terkirim': allSurat.where((s) => s.status == 'Terkirim').length,
            'gagal': allSurat.where((s) => s.status == 'Gagal').length,
          };

          final List<List<Surat>> filteredLists = [
            allSurat.where((s) => s.status == 'Menunggu Kurir').toList(),
            allSurat.where((s) => s.status == 'Dalam Proses').toList(),
            allSurat.where((s) => s.status == 'Terkirim').toList(),
          ];

          return CustomScrollView(
            slivers: [
              _buildHeader(context, 'Ahmad Kurniawan'),
              _buildStatsGrid(stats),
              
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCustomTabBar(stats),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: allSurat.isEmpty
                          ? _buildEmptyList('Tidak ada tugas pengiriman saat ini.')
                          : _buildSuratList(filteredLists[_tabController.index]),
                    ),
                    _buildSummaryCard(stats),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ APPBAR DISESUAIKAN SEPERTI CONTOH
  SliverAppBar _buildHeader(BuildContext context, String namaKurir) {
    return SliverAppBar(
      backgroundColor: lightOrangeBg, // Latar belakang transparan saat di atas
      foregroundColor: Colors.black87,
      pinned: true,
      elevation: 0, // Hilangkan shadow saat di atas
      expandedHeight: 120, // Tinggi header keseluruhan
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.all(16),
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dashboard Kurir', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
                Text(
                  namaKurir,
                  style: GoogleFonts.poppins(
                    color: posBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: posOrange,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStatsGrid(Map<String, int> stats) {
    return SliverToBoxAdapter(
      child: Container(
        color: lightOrangeBg, // Latar belakang sama dengan body
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildStatCard('Menunggu', stats['menunggu'] ?? 0, Icons.watch_later_outlined, const Color(0xFFFFF2E5), posOrange),
            _buildStatCard('Proses', stats['proses'] ?? 0, Icons.local_shipping_outlined, const Color(0xFFEBF4FF), posBlue),
            _buildStatCard('Terkirim', stats['terkirim'] ?? 0, Icons.check_circle_outline, const Color(0xFFEAF7F0), Colors.green.shade600),
            _buildStatCard('Gagal', stats['gagal'] ?? 0, Icons.cancel_outlined, const Color(0xFFFFEBEE), Colors.red.shade600),
          ],
        ),
      ),
    );
  }

  // ... (Sisa kode Anda dari _buildStatCard hingga akhir tidak perlu diubah)

  Widget _buildStatCard(String title, int count, IconData icon, Color bgColor, Color fgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(color: fgColor, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Icon(icon, color: fgColor, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(Map<String, int> stats) {
    final tabs = ['Menunggu', 'Dalam Proses', 'Terkirim'];
    final counts = [stats['menunggu'], stats['proses'], stats['terkirim']];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: posOrange,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: posOrange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(50),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: 'Menunggu (${counts[0] ?? 0})'),
          Tab(text: 'Dalam Proses (${counts[1] ?? 0})'),
          Tab(text: 'Terkirim (${counts[2] ?? 0})'),
        ],
      ),
    );
  }

  Widget _buildSuratList(List<Surat> suratList) {
    return ListView.builder(
      key: ValueKey(_tabController.index), // Key untuk memicu animasi
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suratList.length,
      itemBuilder: (context, index) {
        final surat = suratList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SuratCard(surat: surat, isKurirView: true),
        );
      },
    );
  }

  Widget _buildEmptyList(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      child: Center(
        child: Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, int> stats) {
    int totalDiproses = (stats['proses'] ?? 0) + (stats['terkirim'] ?? 0) + (stats['gagal'] ?? 0);
    double tingkatKeberhasilan = totalDiproses == 0 ? 100 : ((stats['terkirim'] ?? 0) / totalDiproses * 100);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Hari Ini', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: posBlue)),
          const SizedBox(height: 16),
          _buildSummaryItem(stats['terkirim'] ?? 0, 'Surat Terkirim', posOrange),
          const SizedBox(height: 12),
          _buildSummaryItem((stats['proses'] ?? 0), 'Sedang Diproses', posBlue),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tingkat Keberhasilan', style: GoogleFonts.poppins(color: Colors.green.shade800, fontWeight: FontWeight.w600)),
                Text('${tingkatKeberhasilan.toStringAsFixed(0)}%', style: GoogleFonts.poppins(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(int count, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 15)),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(color: color, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}