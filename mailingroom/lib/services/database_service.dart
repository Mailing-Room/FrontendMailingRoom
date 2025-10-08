// Path: lib/services/database_service.dart

import '../models/surat.dart';

class DatabaseService {
  // Data surat dummy
  final List<Surat> _dummySuratList = [
    Surat(
      id: '1',
      nomor: '123/PKS/X/2025',
      perihal: 'Perjanjian Kerja Sama Proyek A',
      deskripsiSurat: 'Dokumen perjanjian kerja sama proyek',
      sifatSurat: 'Penting',
      fileSuratUrl: null,
      lpSuratUrl: null,
      berat: 100.0,
      pengirimAsal: 'PT Sentosa Abadi',
      pengirimDivisi: 'Marketing',
      pengirimDepartemen: 'Sales',
      penerimaTujuan: 'penerima@mailingroom.com',
      penerimaDivisi: 'Keuangan',
      penerimaDepartemen: 'Accounting',
      jenisSurat: 'Masuk',
      status: 'Menunggu Kurir',
      tanggal: '2025-10-08',
    ),
    Surat(
      id: '2',
      nomor: '321/ED/X/2025',
      perihal: 'Surat Edaran Libur Nasional',
      deskripsiSurat: 'Surat edaran resmi mengenai libur nasional',
      sifatSurat: 'Biasa',
      fileSuratUrl: null,
      lpSuratUrl: null,
      berat: 50.0,
      pengirimAsal: 'Divisi HRD',
      pengirimDivisi: 'HR',
      pengirimDepartemen: 'General Affairs',
      penerimaTujuan: 'penerima@mailingroom.com',
      penerimaDivisi: 'Semua',
      penerimaDepartemen: 'Semua',
      jenisSurat: 'Keluar',
      status: 'Terkirim',
      tanggal: '2025-10-07',
    ),
  ];

  // Mengubah Stream menjadi data statis
  Stream<List<Surat>> getSuratList() async* {
    yield _dummySuratList;
  }

  Stream<List<Surat>> getKurirSurat() async* {
    yield _dummySuratList.where((s) => s.status == 'Menunggu Kurir' || s.status == 'Dalam Pengiriman').toList();
  }

  Stream<List<Surat>> getSuratByPenerima(String penerimaEmail) async* {
    yield _dummySuratList.where((s) => s.penerimaTujuan == penerimaEmail).toList();
  }
  
  // Metode tambah, ubah, dan hapus dummy
  Future<void> addSurat(Surat surat) async {
    _dummySuratList.add(surat);
  }

  Future<void> updateSuratStatus(String suratId, String newStatus) async {
    // Tidak melakukan apa-apa
  }

  Future<void> updateSurat(String suratId, Surat surat) async {
    // Tidak melakukan apa-apa
  }
}