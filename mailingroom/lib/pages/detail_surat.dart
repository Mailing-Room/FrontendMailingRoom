// Path: lib/pages/detail_surat_page.dart
import 'package:flutter/material.dart';
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import '../models/surat.dart';

class DetailSuratPage extends StatelessWidget {
  final Surat surat;
  const DetailSuratPage({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    const Color posBlue = Color(0xFF00529C);
    const Color posOrange = Color(0xFFF37021);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Surat'),
        backgroundColor: posBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditSuratPage(surat: surat, isEdit: true),
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(surat.perihal,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // ✅ BAGIAN INI DIPERBAIKI DENGAN LEBIH BAIK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Text nomor surat tetap fleksibel dengan Expanded
                    Expanded(
                      child: Text(
                        "Nomor: ${surat.nomor}",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                        // overflow: TextOverflow.ellipsis, // Opsi jika nomor sangat panjang
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Chip status juga dibuat fleksibel agar bisa mengecil jika perlu
                    Flexible(
                      child: Chip(
                        label: Text(
                          surat.status,
                          overflow: TextOverflow
                              .ellipsis, // Tampilkan '...' jika teks status terlalu panjang
                        ),
                        backgroundColor:
                            surat.status.toLowerCase() == 'terkirim'
                                ? Colors.green.shade100
                                : posOrange.withOpacity(0.2),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: surat.status.toLowerCase() == 'terkirim'
                              ? Colors.green.shade800
                              : posOrange,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 30),
                _buildDetailItem('Deskripsi', surat.deskripsiSurat),
                _buildDetailItem('Sifat Surat', surat.sifatSurat),
                _buildDetailItem('Jenis Surat', surat.jenisSurat),
                _buildDetailItem('Tanggal', surat.tanggal.split('T').first),
                const SizedBox(height: 20),
                _buildSection('📤 Pengirim', posBlue, {
                  'Asal': surat.pengirimAsal,
                  'Divisi': surat.pengirimDivisi,
                  'Departemen': surat.pengirimDepartemen,
                }),
                const SizedBox(height: 20),
                _buildSection('📥 Penerima', posBlue, {
                  'Tujuan': surat.penerimaTujuan,
                  'Divisi': surat.penerimaDivisi,
                  'Departemen': surat.penerimaDepartemen,
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, Color titleColor, Map<String, String?> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
        const SizedBox(height: 8),
        ...data.entries.map((e) => _buildDetailItem(e.key, e.value)).toList(),
      ],
    );
  }
}
