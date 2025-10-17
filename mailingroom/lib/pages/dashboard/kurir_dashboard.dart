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

          final listMenunggu = allSurat.where((s) => s.status == 'Menunggu Kurir').toList();
          final listProses = allSurat.where((s) => s.status == 'Dalam Proses').toList();
          final listTerkirim = allSurat.where((s) => s.status == 'Terkirim').toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildHeader(context, 'Ahmad Kurniawan'),
                _buildStatsGrid(stats),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: posOrange,
                      unselectedLabelColor: Colors.grey[600],
                      indicator: BoxDecoration(
                        color: posOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: [
                        Tab(text: 'Menunggu (${stats['menunggu'] ?? 0})'),
                        Tab(text: 'Proses (${stats['proses'] ?? 0})'),
                        Tab(text: 'Terkirim (${stats['terkirim'] ?? 0})'),
                      ],
                    ),
                    backgroundColor: lightOrangeBg,
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildContentBody(listMenunggu, 'Belum ada surat untuk diambil.', stats),
                _buildContentBody(listProses, 'Tidak ada surat yang sedang dalam proses.', stats),
                _buildContentBody(listTerkirim, 'Belum ada surat yang terkirim hari ini.', stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentBody(List<Surat> suratList, String emptyMessage, Map<String, int> stats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          suratList.isEmpty
              ? _buildEmptyList(emptyMessage)
              : _buildSuratList(suratList),
          _buildSummaryCard(stats),
        ],
      ),
    );
  }

  SliverAppBar _buildHeader(BuildContext context, String namaKurir) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      pinned: true,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset('assets/images/POSIND_2023.svg.png', errorBuilder: (c,e,s) => const SizedBox()),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mailingroom', style: GoogleFonts.poppins(color: posBlue, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(namaKurir, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
      centerTitle: false,
      titleSpacing: 12.0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: posOrange,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildStatsGrid(Map<String, int> stats) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
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

  Widget _buildStatCard(String title, int count, IconData icon, Color bgColor, Color fgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        // Kurangi padding agar tidak overflow
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(color: fgColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Flexible( // Gunakan Flexible untuk memastikan teks pas
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(color: fgColor.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Icon(icon, color: fgColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuratList(List<Surat> suratList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suratList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SuratCard(surat: suratList[index], isKurirView: true),
        );
      },
    );
  }

  Widget _buildEmptyList(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
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
      padding: const EdgeInsets.all(20),
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
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
        Text(count.toString(), style: GoogleFonts.poppins(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar, {required this.backgroundColor});
  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}