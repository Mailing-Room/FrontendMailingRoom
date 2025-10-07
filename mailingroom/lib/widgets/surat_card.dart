// Path: lib/widgets/surat_card.dart

import 'package:flutter/material.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/pages/detail_surat.dart';

class SuratCard extends StatelessWidget {
  final Surat surat;
  final bool isKurirView;

  const SuratCard({
    super.key,
    required this.surat,
    this.isKurirView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: surat.jenisSurat == 'Masuk' ? Colors.blue : Colors.orange,
          child: Icon(
            surat.jenisSurat == 'Masuk' ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(surat.perihal),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('No: ${surat.nomor}'),
            Text('Status: ${surat.status}'),
          ],
        ),
        trailing: isKurirView && surat.status != 'Terkirim'
            ? ElevatedButton(
                onPressed: () {
                  // TODO: Tambahkan logika untuk update status surat
                },
                child: const Text('Ubah Status'),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuratDetailPage(surat: surat)),
          );
        },
      ),
    );
  }
}