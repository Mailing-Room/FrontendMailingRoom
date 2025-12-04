import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart';
import 'package:mailingroom/pages/tracking_page.dart';
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mailingroom/providers/surat_provider.dart';
import 'package:mailingroom/models/surat.dart';

class PengirimDashboard extends StatelessWidget {
  final MyUser user;
  final Function(int, {int subTabIndex}) onNavigateToTab;

  const PengirimDashboard({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan listen: false karena kita akan pakai StreamBuilder
    final suratProvider = Provider.of<SuratProvider>(context, listen: false);

    return SingleChildScrollView(
      // Padding handap disaluyukeun supaya teu panjang teuing
      padding: const EdgeInsets.only(bottom: 20), 
      child: Column(
        children: [
          // 1. HEADER / BANNER
          _buildWelcomeBanner(context),

          // 2. KONTEN UTAMA
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // --- SECTION AKSI CEPAT ---
                    _buildSectionHeader("Aksi Cepat"),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),

                    const SizedBox(height: 32),

                    // --- STREAM BUILDER UTAMA ---
                    StreamBuilder<List<Surat>>(
                      stream: suratProvider.allSuratStream,
                      builder: (context, snapshot) {
                        // Data default jika loading/kosong
                        List<Surat> suratList = [];
                        if (snapshot.hasData) {
                          suratList = snapshot.data!;
                        }

                        // --- HITUNG STATISTIK DI SINI (Manual) ---
                        final int masuk = suratList.where((s) => s.jenisSurat.toLowerCase().contains('masuk')).length;
                        final int keluar = suratList.where((s) => s.jenisSurat.toLowerCase().contains('keluar')).length;
                        final int pending = suratList.where((s) => 
                            s.status.toLowerCase().contains('pending') || 
                            s.status.toLowerCase().contains('menunggu') ||
                            s.status.toLowerCase().contains('proses')
                        ).length;
                        final int selesai = suratList.where((s) => 
                            s.status.toLowerCase().contains('selesai') || 
                            s.status.toLowerCase().contains('terkirim') || 
                            s.status.toLowerCase().contains('diterima')
                        ).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- SECTION STATISTIK ---
                            _buildSectionHeader("Ringkasan Surat"),
                            const SizedBox(height: 16),
                            _buildStatisticsGrid(context, masuk, keluar, pending, selesai),

                            const SizedBox(height: 32),

                            // --- SECTION SURAT TERBARU ---
                            _buildSectionHeader("Surat Terbaru"),
                            const SizedBox(height: 16),
                            
                            if (snapshot.connectionState == ConnectionState.waiting)
                               const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                            else
                               _buildRecentLettersList(context, suratList),
                               
                            // --- PERBAIKAN: Spasi kosong badag dihapus di dieu ---
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: HEADER BANNER ---
  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40), 
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00529C), // Pos Blue
            const Color(0xFF0073E6), // Lighter Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00529C).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Center( 
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFF37021), // Orange
                  child: Text(
                    user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, ${user.nama} 👋",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Selamat datang di Mailing Room",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: GRID AKSI CEPAT ---
  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 20) / 2; 
        if (constraints.maxWidth > 600) {
          itemWidth = (constraints.maxWidth - 45) / 4;
        }

        return Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildActionCard(
              context, "Kirim Surat", "Buat baru", Icons.send_rounded, 
              const Color(0xFFF37021), 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditSuratPage())),
              width: itemWidth,
            ),
            _buildActionCard(
              context, "Lacak Surat", "Cek posisi", Icons.location_searching_rounded, 
              const Color(0xFF28A745), 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingPage())),
              width: itemWidth,
            ),
            _buildActionCard(
              context, "Surat Masuk", "Kotak masuk", Icons.mark_email_unread_rounded, 
              const Color(0xFF00529C), 
              () => onNavigateToTab(1, subTabIndex: 0),
              width: itemWidth,
            ),
            _buildActionCard(
              context, "Surat Keluar", "Riwayat", Icons.outbox_rounded, 
              const Color(0xFFDC3545), 
              () => onNavigateToTab(1, subTabIndex: 1),
              width: itemWidth,
            ),
          ],
        );
      }
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap, {required double width}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: GRID STATISTIK ---
  Widget _buildStatisticsGrid(BuildContext context, int masuk, int keluar, int pending, int selesai) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 20) / 2; 
        if (constraints.maxWidth > 600) {
          itemWidth = (constraints.maxWidth - 45) / 4;
        }

        return Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildStatCard("Masuk", masuk.toString(), Icons.arrow_downward_rounded, Colors.blue, width: itemWidth),
            _buildStatCard("Keluar", keluar.toString(), Icons.arrow_upward_rounded, Colors.orange, width: itemWidth),
            _buildStatCard("Pending", pending.toString(), Icons.hourglass_top_rounded, Colors.amber[700]!, width: itemWidth),
            _buildStatCard("Selesai", selesai.toString(), Icons.check_circle_outline_rounded, Colors.green, width: itemWidth),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 40, color: color.withOpacity(0.2)),
        ],
      ),
    );
  }

  // --- WIDGET: LIST SURAT TERBARU ---
  Widget _buildRecentLettersList(BuildContext context, List<Surat> suratList) {
    if (suratList.isEmpty) {
      return _buildEmptyState();
    }

    // Ambil 5 surat terbaru
    final list = suratList.take(5).toList(); 

    return ListView.separated(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildSuratListItem(list[index]);
      },
    );
  }

  Widget _buildSuratListItem(Surat surat) {
    Color statusColor = Colors.blue;
    String status = surat.status.toLowerCase();
    if (status.contains('selesai') || status.contains('terkirim') || status.contains('diterima')) statusColor = Colors.green;
    else if (status.contains('pending') || status.contains('menunggu')) statusColor = Colors.orange;
    else if (status.contains('gagal')) statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surat.perihal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "No: ${surat.nomor}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              surat.status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "Belum ada surat",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}