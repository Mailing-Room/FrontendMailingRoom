// lib/widgets/surat_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/pages/detail_surat.dart';

class SuratCard extends StatelessWidget {
  final Surat surat;
  final bool isKurirView;

  const SuratCard({super.key, required this.surat, this.isKurirView = false});

  // Fungsi helper untuk warna berdasarkan status
  Map<String, Color> _getStatusStyle(String status, BuildContext context) {
    final s = status.toLowerCase();
    final Color posOrange = Theme.of(context).colorScheme.secondary;
    final Color posBlue = Theme.of(context).colorScheme.primary;

    if (s.contains('menunggu')) {
      return {'bg': posOrange.withOpacity(0.1), 'text': posOrange};
    }
    if (s.contains('proses')) {
      return {'bg': posBlue.withOpacity(0.1), 'text': posBlue};
    }
    if (s.contains('terkirim') || s.contains('selesai') || s.contains('diterima')) {
      return {'bg': Colors.green.shade50, 'text': Colors.green.shade700};
    }
    if (s.contains('gagal')) {
      return {'bg': Colors.red.shade50, 'text': Colors.red.shade700};
    }
    return {'bg': Colors.grey.shade200, 'text': Colors.grey.shade700};
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(surat.status, context);
    final formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(DateTime.parse(surat.tanggal)); // Menggunakan createdAt
    final Color posOrange = Theme.of(context).colorScheme.secondary;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Tombol "Lihat Detail" sekarang menggantikan fungsi onTap utama
          if (!isKurirView) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetailSuratPage(surat: surat)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Baris Tag (Sifat, Jenis) ---
              Row(
                children: [
                  _buildTag(surat.sifatSurat, Colors.red.shade50, Colors.red.shade700),
                  _buildTag(surat.jenisSurat, Colors.blue.shade50, Colors.blue.shade700),
                  // 'berat' tidak ada di model Naskah Anda
                ],
              ),
              const SizedBox(height: 12),

              // --- Judul & Nomor Surat ---
              Text(
                surat.perihal, // Menggunakan 'judul'
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'No. ${surat.nomor}', // Menggunakan 'noSurat'
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
              ),
              if (isKurirView) ...[
                const SizedBox(height: 4),
                 Text(
                  'No. Ref: ${surat.id.substring(0, 8)}', // Contoh No. Referensi
                  style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
              const Divider(height: 24),

              // --- Info Pengirim & Penerima ---
              _buildInfoRow(Icons.person_outline, 'Pengirim:', surat.pengirimAsal), // Menggunakan 'pengirimAsal'
              const SizedBox(height: 8),
              _buildInfoRow(Icons.pin_drop_outlined, 'Penerima:', surat.penerimaTujuan), // Menggunakan 'penerimaTujuan'

              const SizedBox(height: 12),

              // --- Baris Status & Tanggal atau Tombol Aksi ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status & Tanggal untuk view biasa
                  if (!isKurirView)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusChip(statusStyle),
                        const SizedBox(height: 4),
                        Text(formattedDate, style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12)),
                      ],
                    ),
                  
                  // Tombol Aksi untuk view Kurir
                  if (isKurirView)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () { /* TODO: Logika Ambil Surat */ },
                              icon: const Icon(Icons.inventory_2_outlined, size: 18),
                              label: const Text('Ambil Surat'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: posOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => DetailSuratPage(surat: surat)));
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                              label: const Text('Lihat Detail'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                foregroundColor: Colors.grey.shade700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
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

  // Widget helper untuk membuat tag
  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  // Widget helper untuk baris informasi
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              value ?? '-', // Tampilkan '-' jika data null
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // Widget helper untuk chip status
  Widget _buildStatusChip(Map<String, Color> statusStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusStyle['bg'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        surat.status,
        style: GoogleFonts.poppins(color: statusStyle['text'], fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}