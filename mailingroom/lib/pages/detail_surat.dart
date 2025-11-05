// lib/pages/detail_surat_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import '../models/surat.dart'; // Menggunakan model Surat Anda

class DetailSuratPage extends StatelessWidget {
  final Surat surat;
  const DetailSuratPage({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari tema global
    final Color posBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Detail Surat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: posBlue,
        elevation: 1.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Surat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pastikan AddEditSuratPage juga sudah disesuaikan
                  builder: (_) => AddEditSuratPage(surat: surat, isEdit: true),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER UTAMA ---
            _buildPageHeader(context, surat), // ✅ Kirim context

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- KARTU DETAIL SURAT ---
                  _buildInfoCard(
                    context, // ✅ Kirim context
                    title: 'Detail Surat',
                    icon: Icons.article_outlined,
                    children: [
                      _buildDetailRow(icon: Icons.text_snippet_outlined, label: 'Deskripsi', value: surat.perihal),
                      _buildDetailRow(icon: Icons.flag_outlined, label: 'Sifat Naskah', value: surat.sifatSurat),
                      _buildDetailRow(icon: Icons.category_outlined, label: 'Jenis Naskah', value: surat.jenisSurat),
                      _buildDetailRow(icon: Icons.key_outlined, label: 'Kategori ID', value: surat.kategoriId),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- KARTU INFORMASI PIHAK ---
                  _buildInfoCard(
                    context, // ✅ Kirim context
                    title: 'Informasi Pihak',
                    icon: Icons.people_alt_outlined,
                    children: [
                      _buildDetailRow(icon: Icons.upload_file_outlined, label: 'Pengirim ID', value: surat.pengirimId),
                      _buildDetailRow(icon: Icons.downloading_outlined, label: 'Penerima ID', value: surat.penerimaId),
                      _buildDetailRow(icon: Icons.local_shipping_outlined, label: 'Kurir ID', value: surat.kurirId),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // --- KARTU LAMPIRAN ---
                  _buildInfoCard(
                    context, // ✅ Kirim context
                    title: 'Lampiran',
                    icon: Icons.attach_file_outlined,
                    children: [
                      _buildAttachmentTile(
                        context, // ✅ Kirim context
                        icon: Icons.description_outlined,
                        fileName: 'File Surat',
                        fileUrl: surat.fileSuratUrl,
                        onDownload: () {
                          // Logika unduh file surat
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK MEMBUAT HEADER HALAMAN
  Widget _buildPageHeader(BuildContext context, Surat surat) { // ✅ Terima context
    final Color statusColor;
    final String statusText = surat.status;

    if (statusText.toLowerCase().contains('terkirim') || statusText.toLowerCase().contains('diterima')) {
      statusColor = Colors.green.shade600;
    } else if (statusText.toLowerCase().contains('menunggu')) {
      statusColor = Theme.of(context).colorScheme.secondary;
    } else {
      statusColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  surat.nomor,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dibuat pada: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.parse(surat.tanggal))}',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK MEMBUAT KARTU INFORMASI
  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) { // ✅ Terima context
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // WIDGET UNTUK MEMBUAT BARIS DETAIL
  Widget _buildDetailRow({required IconData icon, required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(
                  value ?? '-', // Menampilkan '-' jika data null
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET UNTUK LAMPIRAN
  Widget _buildAttachmentTile(BuildContext context, {required IconData icon, required String fileName, String? fileUrl, VoidCallback? onDownload}) { // ✅ Terima context
    bool hasFile = fileUrl != null && fileUrl.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: hasFile ? Theme.of(context).colorScheme.primary.withOpacity(0.7) : Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(child: Text(fileName, style: GoogleFonts.poppins(color: hasFile ? Colors.black87 : Colors.grey[500]))),
          IconButton(
            icon: Icon(
              Icons.download_for_offline_outlined, 
              color: hasFile ? Theme.of(context).colorScheme.secondary : Colors.grey[300],
            ),
            onPressed: hasFile ? onDownload : null,
            tooltip: hasFile ? 'Unduh File' : 'File tidak tersedia',
          ),
        ],
      ),
    );
  }
}