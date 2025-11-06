// lib/pages/dashboard/pengirim_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart'; // ✅ Import model user
import 'package:provider/provider.dart';

import '../../models/surat.dart';
import '../../providers/surat_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/surat_card.dart';
import '../add_edit_surat_pages.dart';
import '../tracking_page.dart';

class PengirimDashboard extends StatelessWidget {
  final Function(int, {int subTabIndex}) onNavigateToTab;
  //PERBAIKAN: Terima object MyUser
  final MyUser user;

  const PengirimDashboard({
    super.key, 
    required this.user, 
    required this.onNavigateToTab
  });

  // Warna tema
  static const Color posOrange = Color(0xFFF37021);
  static const Color posBlue = Color(0xFF00529C);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuratProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<List<Surat>>(
        stream: provider.allSuratStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: posOrange));
          }
          final suratList = snapshot.data ?? [];
          
          final suratMasukCount = suratList.where((s) => s.jenisSurat == 'Masuk').length;
          final suratKeluarCount = suratList.where((s) => s.jenisSurat == 'Keluar').length;
          final selesaiCount = suratList.where((s) => s.status.toLowerCase().contains('terkirim')).length;
          final pendingCount = suratList.length - selesaiCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, ${user.nama}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Selamat datang di Mailingroom POS IND', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                Text('Aksi Cepat', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.8,
                  children: [
                    _quickActionCard('Kirim Surat', Icons.add_circle_outline, posOrange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage()))),
                    _quickActionCard('Lacak Surat', Icons.travel_explore_rounded, Colors.green.shade600, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackingPage()))),
                    _quickActionCard('Surat Masuk', Icons.inbox_outlined, posBlue, () => onNavigateToTab(1, subTabIndex: 0)),
                    _quickActionCard('Surat Keluar', Icons.send_outlined, Colors.deepOrange, () => onNavigateToTab(1, subTabIndex: 1)),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Statistik', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    _statCard('Surat Masuk', suratMasukCount, Icons.inbox, posBlue),
                    _statCard('Surat Keluar', suratKeluarCount, Icons.send, posOrange),
                    _statCard('Pending', pendingCount, Icons.watch_later, Colors.amber.shade700),
                    _statCard('Selesai', selesaiCount, Icons.check_circle, Colors.green.shade600),
                  ],
                ),
                const SizedBox(height: 24),
                SectionHeader(title: 'Surat Terbaru', onAction: () => onNavigateToTab(1)),
                const SizedBox(height: 8),
                if (suratList.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Belum ada surat.')))
                else
                  ListView.separated(
                    itemCount: suratList.length > 3 ? 3 : suratList.length, // Tampilkan 3 surat terbaru
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => SuratCard(surat: suratList[index]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}