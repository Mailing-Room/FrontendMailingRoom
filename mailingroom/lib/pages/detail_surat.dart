// Path: lib/pages/surat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/models/user.dart';
import 'package:mailingroom/services/database_service.dart';

class SuratDetailPage extends StatelessWidget {
  final Surat surat;

  const SuratDetailPage({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);
    final isKurir = user?.role == 'kurir';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Surat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailCard('Nomor Surat', surat.nomor),
            _buildDetailCard('Perihal', surat.perihal),
            _buildDetailCard('Jenis Surat', surat.jenisSurat),
            _buildDetailCard('Pengirim Asal', surat.pengirimAsal),
            if (surat.penerimaTujuan != null)
              _buildDetailCard('Penerima Tujuan', surat.penerimaTujuan!),
            _buildDetailCard('Tanggal', surat.tanggal),
            const SizedBox(height: 20),
            _buildStatusCard(surat.status),
            const SizedBox(height: 20),
            _buildTrackingSection(surat.status, surat.id!, isKurir),
            const SizedBox(height: 20),
            if (isKurir && surat.status != 'Terkirim')
              _buildKurirActions(context, surat),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    return Card(
      color: Colors.lightBlue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Surat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingSection(String status, String suratId, bool isKurir) {
    // TODO: Implementasi logika riwayat tracking
    return const SizedBox.shrink();
  }

  Widget _buildKurirActions(BuildContext context, Surat surat) {
    final String nextStatus = surat.status == 'Menunggu Kurir' ? 'Dalam Pengiriman' : 'Terkirim';
    return ElevatedButton(
      onPressed: () {
        DatabaseService().updateSuratStatus(surat.id!, nextStatus);
        Navigator.pop(context);
      },
      child: Text('Ubah Status ke "$nextStatus"'),
    );
  }
}