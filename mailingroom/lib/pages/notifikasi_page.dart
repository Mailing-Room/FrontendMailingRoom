// lib/pages/notifikasi_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

// ❗ PENTING: Tambahkan package ini jika belum ada
// flutter pub add collection intl

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

  Map<String, dynamic> _getIconForType(String tipe) {
    switch (tipe) {
      case 'selesai':
        return {'icon': Icons.check_circle, 'color': Colors.green.shade600};
      case 'surat_masuk':
        return {'icon': Icons.inbox, 'color': posBlue};
      case 'pengiriman':
        return {'icon': Icons.local_shipping, 'color': posOrange};
      case 'gagal':
        return {'icon': Icons.error, 'color': Colors.red.shade600};
      case 'verifikasi':
        return {'icon': Icons.verified_user, 'color': Colors.cyan.shade600};
      default:
        return {'icon': Icons.notifications, 'color': Colors.grey.shade600};
    }
  }

  void _tandaiSemuaDibaca() {
    setState(() {
      for (var notif in _daftarNotifikasi) {
        notif.sudahDibaca = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca.'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifikasi = groupBy(
      _daftarNotifikasi,
      (Notifikasi notif) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final notifDate = DateTime(notif.tanggal.year, notif.tanggal.month, notif.tanggal.day);

        if (notifDate == today) {
          return 'Hari Ini';
        } else if (notifDate == yesterday) {
          return 'Kemarin';
        } else {
          return 'Lama';
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ✅ AppBar ditambahkan dan diberi tema
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1.0,
        titleSpacing: 16.0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            color: posBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (_daftarNotifikasi.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _tandaiSemuaDibaca,
                child: Text('Tandai semua dibaca', style: GoogleFonts.poppins(color: posBlue)),
              ),
            ),
        ],
      ),
      body: _daftarNotifikasi.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: groupedNotifikasi.keys.length,
              itemBuilder: (context, index) {
                final groupTitle = groupedNotifikasi.keys.elementAt(index);
                final notifList = groupedNotifikasi[groupTitle]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 4.0),
                        child: Text(
                          groupTitle,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                      ),
                      ...notifList.map((notif) {
                        return _buildNotificationCard(notif);
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/pos_notification.png', height: 180, errorBuilder: (c, e, s) => Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300])),
          const SizedBox(height: 24),
          Text('Tidak Ada Notifikasi', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: posBlue)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Semua pemberitahuan baru akan muncul di sini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Notifikasi notifikasi) {
    final style = _getIconForType(notifikasi.tipe);
    final iconData = style['icon'] as IconData;
    final iconColor = style['color'] as Color;
    final itemIndex = _daftarNotifikasi.indexOf(notifikasi);

    return Dismissible(
      key: Key(notifikasi.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _daftarNotifikasi.removeAt(itemIndex);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${notifikasi.judul} dihapus'), duration: const Duration(seconds: 2)),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notifikasi.sudahDibaca ? 0.5 : 3.0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notifikasi.sudahDibaca
              ? BorderSide(color: Colors.grey[200]!)
              : BorderSide(color: posBlue.withOpacity(0.5), width: 1.5), // ✅ Border biru untuk notif baru
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              notifikasi.sudahDibaca = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    // ✅ Latar belakang ikon lebih soft
                    color: notifikasi.sudahDibaca ? Colors.grey.shade200 : iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: notifikasi.sudahDibaca ? Colors.grey.shade500 : iconColor),
                ),
                const SizedBox(width: 16),
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
                              style: GoogleFonts.poppins(
                                fontWeight: notifikasi.sudahDibaca ? FontWeight.w500 : FontWeight.bold,
                                fontSize: 15,
                                color: notifikasi.sudahDibaca ? Colors.grey[700] : posBlue, // ✅ Judul biru untuk notif baru
                              ),
                            ),
                          ),
                          // ✅ Titik oranye sebagai indikator notif baru
                          if (!notifikasi.sudahDibaca)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: posOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notifikasi.pesan,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: notifikasi.sudahDibaca ? Colors.grey[600] : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('d MMM yyyy, HH:mm').format(notifikasi.tanggal),
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}