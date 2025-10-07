// Path: lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailingroom/models/surat.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan stream semua surat (untuk Dashboard Pengirim)
  Stream<List<Surat>> getSuratList() {
    return _db.collection('surat')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Surat.fromFirestore(doc)).toList());
  }

  // Mendapatkan stream surat yang relevan untuk kurir (status 'Menunggu Kurir' atau 'Dalam Pengiriman')
  Stream<List<Surat>> getKurirSurat() {
    return _db.collection('surat')
        .where('status', whereIn: ['Menunggu Kurir', 'Dalam Pengiriman'])
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Surat.fromFirestore(doc)).toList());
  }

  // Mendapatkan stream surat yang ditujukan ke penerima tertentu
  Stream<List<Surat>> getSuratByPenerima(String penerimaEmail) {
    return _db.collection('surat')
        .where('penerimaTujuan', isEqualTo: penerimaEmail)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Surat.fromFirestore(doc)).toList());
  }
  
  // Menambah surat baru
  Future<void> addSurat(Surat surat) {
    return _db.collection('surat').add(surat.toMap());
  }

  // Mengubah status surat
  Future<void> updateSuratStatus(String suratId, String newStatus) {
    return _db.collection('surat').doc(suratId).update({'status': newStatus});
  }

  // Mengubah detail surat yang sudah ada
  Future<void> updateSurat(String suratId, Surat surat) {
    return _db.collection('surat').doc(suratId).update(surat.toMap());
  }
}