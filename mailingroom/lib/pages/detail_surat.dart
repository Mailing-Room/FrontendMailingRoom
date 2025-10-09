// Path: lib/pages/detail_surat_page.dart
import 'package:flutter/material.dart';
import 'package:mailingroom/pages/add_edit_surat_pages.dart';
import '../models/surat.dart';

class DetailSuratPage extends StatelessWidget {
  final Surat surat;
  const DetailSuratPage({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade700;
    final Color accentColor = Colors.orange.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Surat'),
        backgroundColor: primaryColor,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(surat.perihal,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Nomor: ${surat.nomor}", style: const TextStyle(fontSize: 16)),
                    Chip(
                      label: Text(surat.status),
                      backgroundColor: surat.status == 'Terkirim'
                          ? Colors.green.shade200
                          : accentColor.withOpacity(0.3),
                    ),
                  ],
                ),
                const Divider(height: 30),
                _buildDetailItem('Deskripsi', surat.deskripsiSurat),
                _buildDetailItem('Sifat Surat', surat.sifatSurat),
                _buildDetailItem('Jenis Surat', surat.jenisSurat),
                _buildDetailItem('Tanggal', surat.tanggal),
                const SizedBox(height: 20),
                _buildSection('📤 Pengirim', {
                  'Asal': surat.pengirimAsal,
                  'Divisi': surat.pengirimDivisi,
                  'Departemen': surat.pengirimDepartemen,
                }),
                const SizedBox(height: 20),
                _buildSection('📥 Penerima', {
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Map<String, String?> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 8),
        ...data.entries.map((e) => _buildDetailItem(e.key, e.value)).toList(),
      ],
    );
  }
}
