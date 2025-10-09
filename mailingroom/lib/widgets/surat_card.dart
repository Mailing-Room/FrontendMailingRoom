// Path: lib/widgets/surat_card.dart
import 'package:flutter/material.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/pages/detail_surat.dart';

class SuratCard extends StatelessWidget {
  final Surat surat;
  final bool isKurirView;

  const SuratCard({super.key, required this.surat, this.isKurirView = false});

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('menunggu')) return Colors.orange;
    if (s.contains('dalam')) return Colors.orange.shade700;
    if (s.contains('terkirim') || s.contains('selesai')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(surat.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => DetailSuratPage(surat: surat)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // badges row
            Row(children: [
              if (surat.sifatSurat.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(surat.sifatSurat,
                      style: const TextStyle(color: Colors.red)),
                ),
              if (surat.jenisSurat.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(surat.jenisSurat,
                      style: const TextStyle(color: Colors.blue)),
                ),
              if (surat.berat != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${surat.berat?.toStringAsFixed(0)}g',
                      style: const TextStyle(color: Colors.black54)),
                ),
            ]),

            const SizedBox(height: 12),
            Text(surat.perihal,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('No. ${surat.nomor}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengirim:',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(surat.pengirimAsal,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (surat.penerimaTujuan != null) ...[
                      const SizedBox(height: 8),
                      Text('Penerima:',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(surat.penerimaTujuan!,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ]),
            ),

            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Wrap(spacing: 8, children: [
                Chip(
                    label: Text(surat.status,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold)),
                    backgroundColor: statusColor.withOpacity(0.12)),
                if (surat.fileSuratUrl != null) const Chip(label: Text('File')),
                if (surat.lpSuratUrl != null) const Chip(label: Text('LP')),
              ]),
              Text(surat.tanggal.split('T').first,
                  style: const TextStyle(color: Colors.black45))
            ]),
          ]),
        ),
      ),
    );
  }
}
