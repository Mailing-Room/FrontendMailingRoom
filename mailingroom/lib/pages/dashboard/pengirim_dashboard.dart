// lib/pages/dashboard/pengirim_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart';
import 'package:mailingroom/pages/tracking_page.dart'; // Import halaman pelacakan
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import 'package:intl/intl.dart'; // ✅ Import intl untuk format tanggal

// ✅ Import provider dan model Anda
import 'package:mailingroom/providers/surat_provider.dart'; 
import 'package:mailingroom/models/surat.dart';

// --- MODEL UNTUK AKSI CEPAT ---
class AksiCepatItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  AksiCepatItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// --- MODEL UNTUK STATISTIK ---
class StatistikItem {
  final String title;
  final String count;
  final Color color;

  StatistikItem({required this.title, required this.count, required this.color});
}

// --- WIDGET UTAMA ---
class PengirimDashboard extends StatelessWidget {
  final MyUser user;
  final Function(int, {int subTabIndex}) onNavigateToTab;

  const PengirimDashboard({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  // Helper untuk warna status
  Color _getStatusColor(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s.contains('terkirim') || s.contains('diterima') || s.contains('selesai')) return Colors.green.shade600;
    if (s.contains('menunggu') || s.contains('dalam perjalanan') || s.contains('pending')) return Theme.of(context).colorScheme.secondary;
    if (s.contains('gagal')) return Colors.red.shade600;
    return Theme.of(context).colorScheme.primary;
  }
  
  Color _getSifatColor(BuildContext context, String sifat) {
    final s = sifat.toLowerCase();
    if (s.contains('penting')) return Colors.red.shade600;
    if (s.contains('segera')) return Theme.of(context).colorScheme.secondary;
    return Colors.blue.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final Color posOrange = Theme.of(context).colorScheme.secondary;
    final Color posBlue = Theme.of(context).colorScheme.primary;
    
    final suratProvider = Provider.of<SuratProvider>(context, listen: false);

    final List<AksiCepatItem> aksiCepatList = [
      AksiCepatItem(
        title: 'Kirim Surat',
        subtitle: 'Kirim surat baru',
        icon: Icons.add_outlined,
        color: posOrange,
        onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const AddEditSuratPage())
           );
        },
      ),
      AksiCepatItem(
        title: 'Tracking Surat',
        subtitle: 'Lacak posisi surat',
        icon: Icons.track_changes_outlined,
        color: Colors.green.shade600,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrackingPage()),
          );
        },
      ),
      AksiCepatItem(
        title: 'Surat Masuk',
        subtitle: 'Lihat kotak masuk',
        icon: Icons.inbox_outlined,
        color: posBlue,
        onTap: () {
          onNavigateToTab(1, subTabIndex: 0); // Pindah ke tab Surat Masuk
        },
      ),
      AksiCepatItem(
        title: 'Surat Keluar',
        subtitle: 'Lihat surat terkirim',
        icon: Icons.outbox_outlined,
        color: Colors.red.shade600,
        onTap: () {
          onNavigateToTab(1, subTabIndex: 1); // Pindah ke tab Surat Keluar
        },
      ),
    ];

    return SingleChildScrollView(
      // Padding diatur agar konsisten dengan AppBar
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Grid Aksi Cepat (Responsive) ---
          _buildSectionTitle('Aksi Cepat'),
          // Gunakan LayoutBuilder untuk membuat grid responsif
          LayoutBuilder(
            builder: (context, constraints) {
              // Tentukan jumlah kolom berdasarkan lebar yang tersedia
              int crossAxisCount = (constraints.maxWidth < 600) ? 2 : 4;
              // Tentukan rasio aspek agar kartu tidak terlalu tinggi
              double childAspectRatio = (constraints.maxWidth < 600) ? 2.5 : 3.0;
              
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio, 
                children: aksiCepatList.map((item) {
                  return _AksiCepatCard(item: item);
                }).toList(),
              );
            }
          ),
          const SizedBox(height: 24),

          // --- Statistik & Surat Terbaru (dari Stream) ---
          StreamBuilder<List<Surat>>(
            stream: suratProvider.allSuratStream, 
            builder: (context, snapshot) {
              
              List<Surat> suratList = [];
              if (snapshot.hasData) {
                suratList = snapshot.data!;
              }

              // Hitung statistik
              final int suratMasukCount = suratList.where((s) => s.jenisSurat.toLowerCase().contains('internal')).length; // Sesuaikan
              final int suratKeluarCount = suratList.where((s) => s.jenisSurat.toLowerCase().contains('eksternal')).length; // Sesuaikan
              final int pendingCount = suratList.where((s) => (s.status.toLowerCase().contains('pending') || s.status.toLowerCase().contains('menunggu'))).length;
              final int selesaiCount = suratList.where((s) => (s.status.toLowerCase().contains('selesai') || s.status.toLowerCase().contains('terkirim') || s.status.toLowerCase().contains('diterima'))).length;

              final List<StatistikItem> statistikList = [
                StatistikItem(title: 'Surat Masuk', count: suratMasukCount.toString(), color: posBlue),
                StatistikItem(title: 'Surat Keluar', count: suratKeluarCount.toString(), color: posOrange),
                StatistikItem(title: 'Pending', count: pendingCount.toString(), color: Colors.amber.shade700),
                StatistikItem(title: 'Selesai', count: selesaiCount.toString(), color: Colors.green.shade600),
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Grid Statistik (Responsive) ---
                  _buildSectionTitle('Statistik'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = (constraints.maxWidth < 600) ? 2 : 4;
                      double childAspectRatio = (constraints.maxWidth < 600) ? 2.2 : 2.5;

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: childAspectRatio,
                        children: statistikList.map((item) {
                          return _StatistikCard(item: item);
                        }).toList(),
                      );
                    }
                  ),
                  const SizedBox(height: 24),

                  // --- Daftar Surat Terbaru ---
                  _buildSectionTitle('Surat Terbaru'),
                  
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
                  else if (snapshot.hasError)
                    const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Gagal memuat data surat.')))
                  else if (suratList.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Tidak ada surat terbaru.')))
                  else
                    ListView.builder(
                      itemCount: suratList.length > 5 ? 5 : suratList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final surat = suratList[index]; 
                        return _SuratCard(
                          surat: surat,
                          statusColor: _getStatusColor(context, surat.status),
                          sifatColor: _getSifatColor(context, surat.sifatSurat),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// --- WIDGET KARTU AKSI CEPAT ---
class _AksiCepatCard extends StatelessWidget {
  final AksiCepatItem item;
  const _AksiCepatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis, // Hindari overflow teks
                    ),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET KARTU STATISTIK ---
class _StatistikCard extends StatelessWidget {
  final StatistikItem item;
  const _StatistikCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.count,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET KARTU SURAT ---
class _SuratCard extends StatelessWidget {
  final Surat surat;
  final Color statusColor;
  final Color sifatColor;

  const _SuratCard({
    required this.surat,
    required this.statusColor,
    required this.sifatColor,
  });

  String _formatTanggal(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal);
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTagChip(surat.sifatSurat, sifatColor),
                const SizedBox(width: 8),
                _buildTagChip(surat.jenisSurat, Theme.of(context).colorScheme.primary, isSolid: false),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              surat.perihal,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No. ${surat.nomor}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Pengirim:', surat.pengirimAsal),
            const SizedBox(height: 8),
            _buildInfoRow('Penerima:', surat.penerimaTujuan ?? '-'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(surat.status, statusColor),
                Text(
                  _formatTanggal(surat.tanggal),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, Color color, {bool isSolid = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isSolid ? null : Border.all(color: color.withOpacity(0.7), width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSolid ? color : color.withOpacity(0.9),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}