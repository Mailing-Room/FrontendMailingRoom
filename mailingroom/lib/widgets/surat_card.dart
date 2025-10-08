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
    final isMasuk = surat.jenisSurat == 'Masuk';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMasuk ? Colors.blue.shade100 : Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
            color: isMasuk ? Colors.blue : Colors.orange,
          ),
        ),
        title: Text(
          surat.perihal,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nomor Surat: ${surat.nomor}'),
              Text(
                'Status: ${surat.status}',
                style: TextStyle(
                  color: surat.status == 'Terkirim' ? Colors.green : Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
        trailing: isKurirView && surat.status != 'Terkirim'
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onPressed: () {
                  // TODO: Tambahkan logika untuk ubah status surat
                },
                child: const Text(
                  'Ubah',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
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
