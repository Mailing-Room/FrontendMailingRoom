import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart';
import 'package:provider/provider.dart';
import '../../models/surat.dart';
import '../../providers/surat_provider.dart';
import '../../widgets/surat_card.dart';

class KurirDashboard extends StatefulWidget {
  final MyUser user;
  const KurirDashboard({super.key, required this.user});

  @override
  State<KurirDashboard> createState() => _KurirDashboardState();
}

class _KurirDashboardState extends State<KurirDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Color posOrange;
  late Color posBlue;
  final Color lightOrangeBg = const Color(0xFFFFF7F2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    posOrange = Theme.of(context).colorScheme.secondary;
    posBlue = Theme.of(context).colorScheme.primary;
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
            return Center(
              child: CircularProgressIndicator(color: posOrange),
            );
          }

          final allSurat = snapshot.data ?? [];

          final stats = {
            'menunggu':
                allSurat.where((s) => s.status == 'Menunggu Kurir').length,
            'proses': allSurat.where((s) => s.status == 'Dalam Proses').length,
            'terkirim': allSurat.where((s) => s.status == 'Terkirim').length,
            'gagal': allSurat.where((s) => s.status == 'Gagal').length,
          };

          final listMenunggu =
              allSurat.where((s) => s.status == 'Menunggu Kurir').toList();
          final listProses =
              allSurat.where((s) => s.status == 'Dalam Proses').toList();
          final listTerkirim =
              allSurat.where((s) => s.status == 'Terkirim').toList();
          final listGagal =
              allSurat.where((s) => s.status == 'Gagal').toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildHeader(context, widget.user.nama),
                _buildStatsGrid(stats),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: posBlue,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Menunggu (${stats['menunggu'] ?? 0})'),
                        Tab(text: 'Proses (${stats['proses'] ?? 0})'),
                        Tab(text: 'Terkirim (${stats['terkirim'] ?? 0})'),
                        Tab(text: 'Gagal (${stats['gagal'] ?? 0})'),
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
                _buildContentBody(listGagal, 'Tidak ada surat yang gagal.', stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentBody(
      List<Surat> suratList, String emptyMessage, Map<String, int> stats) {
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

  // HEADER — Logo POSIND di kiri, teks di tengah
  SliverAppBar _buildHeader(BuildContext context, String namaKurir) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      elevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Kiri: logo POSIND
          Image.asset(
            'assets/images/POSIND_2023.svg.png',
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.apartment_rounded,
                    color: Colors.orange, size: 40),
          ),
          const SizedBox(width: 10),
          // Tengah: teks
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mailing Room',
                style: GoogleFonts.poppins(
                  color: posBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                namaKurir,
                style: GoogleFonts.poppins(
                    color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GRID STATUS
  SliverToBoxAdapter _buildStatsGrid(Map<String, int> stats) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 400 ? 2 : 4;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.0,
              ),
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final titles = ['Menunggu', 'Proses', 'Terkirim', 'Gagal'];
                final icons = [
                  Icons.access_time_filled_rounded, // Menunggu
                  Icons.delivery_dining_rounded, // Proses
                  Icons.check_circle_rounded, // Terkirim
                  Icons.error_rounded, // Gagal
                ];
                final colors = [
                  Colors.orange,
                  Colors.blue,
                  Colors.green,
                  Colors.red
                ];
                final bgColors = [
                  Colors.orange.shade100,
                  Colors.blue.shade100,
                  Colors.green.shade100,
                  Colors.red.shade100
                ];
                final key = titles[index].toLowerCase();
                return _buildStatCard(
                  titles[index],
                  stats[key] ?? 0,
                  icons[index],
                  bgColors[index],
                  colors[index],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, int count, IconData icon, Color bgColor, Color fgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: fgColor, size: 30),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              color: fgColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: fgColor.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  // Logo kurir di bawah teks kosong
  Widget _buildEmptyList(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Image.asset(
            'assets/images/kurirpos.png',
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.delivery_dining,
                    size: 80, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, int> stats) {
    int totalDiproses =
        (stats['proses'] ?? 0) + (stats['terkirim'] ?? 0) + (stats['gagal'] ?? 0);
    double tingkatKeberhasilan =
        totalDiproses == 0 ? 100 : ((stats['terkirim'] ?? 0) / totalDiproses * 100);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Hari Ini',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: posBlue)),
          const SizedBox(height: 16),
          _buildSummaryItem(stats['terkirim'] ?? 0, 'Surat Terkirim', Colors.green),
          const SizedBox(height: 12),
          _buildSummaryItem(stats['proses'] ?? 0, 'Sedang Diproses', Colors.blue),
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tingkat Keberhasilan',
                    style: GoogleFonts.poppins(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600)),
                Text('${tingkatKeberhasilan.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
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
        Text(label,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 15)),
        Text(count.toString(),
            style: GoogleFonts.poppins(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
