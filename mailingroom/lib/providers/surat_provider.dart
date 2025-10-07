// Path: lib/providers/surat_provider.dart

import 'package:flutter/foundation.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/services/database_service.dart';

class SuratProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Stream untuk semua surat (untuk Pengirim)
  Stream<List<Surat>> get allSuratStream => _databaseService.getSuratList();

  // Stream untuk surat kurir (untuk Kurir)
  Stream<List<Surat>> get kurirSuratStream => _databaseService.getKurirSurat();

  // Stream untuk surat penerima (untuk Penerima)
  Stream<List<Surat>> getPenerimaSuratStream(String penerimaEmail) {
    return _databaseService.getSuratByPenerima(penerimaEmail);
  }

  // Menambah surat baru
  Future<void> addSurat(Surat surat) async {
    await _databaseService.addSurat(surat);
    notifyListeners();
  }

  // Mengubah status surat
  Future<void> updateSuratStatus(String suratId, String newStatus) async {
    await _databaseService.updateSuratStatus(suratId, newStatus);
    notifyListeners();
  }
}