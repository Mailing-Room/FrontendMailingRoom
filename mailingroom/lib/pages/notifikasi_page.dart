import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart'; // Pastikan package ini ada

// --- Model Data Notifikasi ---
class Notifikasi {
  final String id;
  final String judul;
  final String pesan;
  final String tipe;
  final DateTime tanggal;
  bool sudahDibaca;

  Notifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.tanggal,
    this.sudahDibaca = false,
  });
}

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // Warna khas Pos Indonesia
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);

  // Data notifikasi contoh
  final List<Notifikasi> _daftarNotifikasi = [
    Notifikasi(id: '1', judul: 'Status Diperbarui', pesan: 'Surat No. 123/PKS/X/2025 telah sampai di tujuan.', tipe: 'selesai', tanggal: DateTime.now(), sudahDibaca: false),
    Notifikasi(id: '2', judul: 'Surat Masuk Baru', pesan: 'Anda menerima surat baru dari Divisi HRD.', tipe: 'surat_masuk', tanggal: DateTime.now().subtract(const Duration(hours: 2)), sudahDibaca: false),
    Notifikasi(id: '3', judul: 'Pengiriman Diproses', pesan: 'Surat Edaran Libur Nasional sedang dalam perjalanan.', tipe: 'pengiriman', tanggal: DateTime.now().subtract(const Duration(days: 1)), sudahDibaca: true),
    Notifikasi(id: '4', judul: 'Gagal Kirim', pesan: 'Pengiriman surat ke PT Sejahtera gagal, alamat tidak valid.', tipe: 'gagal', tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 5)), sudahDibaca: true),
    Notifikasi(id: '5', judul: 'Verifikasi Berhasil', pesan: 'Surat perjanjian kerjasama telah diverifikasi.', tipe: 'verifikasi', tanggal: DateTime.now().subtract(const Duration(days: 2)), sudahDibaca: true),
  ];

  Map<String, dynamic> _getStyleForType(String tipe) {
    switch (tipe) {
      case 'selesai':
        return {'icon': Icons.check_circle_outline_rounded, 'color': Colors.green.shade600, 'bg': Colors.green.shade50};
      case 'surat_masuk':
        return {'icon': Icons.mark_email_unread_outlined, 'color': posBlue, 'bg': Colors.blue.shade50};
      case 'pengiriman':
        return {'icon': Icons.local_shipping_outlined, 'color': posOrange, 'bg': Colors.orange.shade50};
      case 'gagal':
        return {'icon': Icons.error_outline_rounded, 'color': Colors.red.shade600, 'bg': Colors.red.shade50};
      case 'verifikasi':
        return {'icon': Icons.verified_user_outlined, 'color': Colors.teal.shade600, 'bg': Colors.teal.shade50};
      default:
        return {'icon': Icons.notifications_outlined, 'color': Colors.grey.shade600, 'bg': Colors.grey.shade100};
    }
  }

  void _tandaiSemuaDibaca() {
    setState(() {
      for (var notif in _daftarNotifikasi) {
        notif.sudahDibaca = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Semua notifikasi ditandai sudah dibaca.', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: posBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan notifikasi berdasarkan tanggal
    final groupedNotifikasi = groupBy(_daftarNotifikasi, (Notifikasi notif) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final notifDate = DateTime(notif.tanggal.year, notif.tanggal.month, notif.tanggal.day);

      if (notifDate == today) return 'Hari Ini';
      if (notifDate == yesterday) return 'Kemarin';
      return 'Lama';
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu-abu sangat muda
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0, // Flat style
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
        titleSpacing: 20.0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (_daftarNotifikasi.any((n) => !n.sudahDibaca)) // Hanya tampil jika ada yg belum dibaca
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                onPressed: _tandaiSemuaDibaca,
                icon: Icon(Icons.done_all_rounded, size: 18, color: posBlue),
                label: Text(
                  'Tandai dibaca', 
                  style: GoogleFonts.plusJakartaSans(color: posBlue, fontWeight: FontWeight.w600, fontSize: 13)
                ),
                style: TextButton.styleFrom(
                  backgroundColor: posBlue.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
      body: _daftarNotifikasi.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100), // Padding bawah agar tidak ketutup navbar
              itemCount: groupedNotifikasi.keys.length,
              itemBuilder: (context, index) {
                final groupTitle = groupedNotifikasi.keys.elementAt(index);
                final notifList = groupedNotifikasi[groupTitle]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Text(
                        groupTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey[500],
                          letterSpacing: 0.5
                        ),
                      ),
                    ),
                    ...notifList.map((notif) => _buildNotificationItem(notif)).toList(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text('Tidak Ada Notifikasi', 
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Semua pemberitahuan penting mengenai surat Anda akan muncul di sini.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Notifikasi notifikasi) {
    final style = _getStyleForType(notifikasi.tipe);
    final iconData = style['icon'] as IconData;
    final iconColor = style['color'] as Color;
    final bgColor = style['bg'] as Color;

    return Dismissible(
      key: Key(notifikasi.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade500,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        setState(() {
          _daftarNotifikasi.removeWhere((item) => item.id == notifikasi.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notifikasi dihapus', style: GoogleFonts.plusJakartaSans())),
        );
      },
      child: InkWell(
        onTap: () {
          setState(() {
            notifikasi.sudahDibaca = true;
          });
        },
        // Highlight background jika belum dibaca
        child: Container(
          color: notifikasi.sudahDibaca ? Colors.transparent : posBlue.withOpacity(0.03),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon Notifikasi
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notifikasi.sudahDibaca ? Colors.grey.shade100 : bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData, 
                  color: notifikasi.sudahDibaca ? Colors.grey.shade400 : iconColor,
                  size: 24
                ),
              ),
              const SizedBox(width: 16),
              
              // Konten Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notifikasi.judul,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: notifikasi.sudahDibaca ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 15,
                              color: notifikasi.sudahDibaca ? Colors.black87 : Colors.black,
                            ),
                          ),
                        ),
                        // Waktu
                        Text(
                          _formatTime(notifikasi.tanggal),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, 
                            color: notifikasi.sudahDibaca ? Colors.grey[400] : posBlue,
                            fontWeight: notifikasi.sudahDibaca ? FontWeight.normal : FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notifikasi.pesan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: notifikasi.sudahDibaca ? Colors.grey[600] : Colors.black87,
                        height: 1.4
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!notifikasi.sudahDibaca) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: posOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Baru",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: posOrange,
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
              
              // Indikator Belum Dibaca (Titik) - Opsional, sudah diganti background
              // if (!notifikasi.sudahDibaca)
              //   Padding(
              //     padding: const EdgeInsets.only(left: 8.0, top: 4),
              //     child: CircleAvatar(radius: 4, backgroundColor: posOrange),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j yang lalu';
    } else {
      return DateFormat('HH:mm').format(date);
    }
  }
}