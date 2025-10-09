// Path: lib/pages/dashboard/penerima_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/surat_provider.dart';
import '../../widgets/surat_card.dart';
import '../../models/surat.dart';

class PenerimaDashboard extends StatelessWidget {
  const PenerimaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SuratProvider>(context, listen: false);
    const email = 'penerima@mailingroom.com';

    return Scaffold(
      appBar: AppBar(title: const Text('Kotak Masuk'), backgroundColor: Colors.green),
      body: StreamBuilder<List<Surat>>(
        stream: provider.getPenerimaSuratStream(email),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text('Tidak ada surat untuk Anda.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => SuratCard(surat: list[i]),
          );
        },
      ),
    );
  }
}
