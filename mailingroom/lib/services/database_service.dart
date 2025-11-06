// lib/services/database_service.dart

import '../models/surat.dart'; // Memanggil model Surat yang sudah benar

class DatabaseService {
  // Data surat dummy yang sudah dicocokkan dengan model Surat (Naskah)
  final List<Surat> _dummySuratList = [
    Surat(
      id: 'naskah_id_1',
      nomor: '123/PKS/X/2025',
      perihal: 'Perjanjian Kerja Sama Proyek A',
      deskripsiSurat: 'Dokumen perjanjian kerja sama proyek',
      sifatSurat: 'Penting',
      jenisSurat: 'Masuk',
      status: 'Menunggu Kurir',
      tanggal: '2025-10-13T11:00:00Z', // Menggunakan format ISO (createdAt)
      pengirimId: 'user-pengirim-123',
      pengirimAsal: 'PT Sentosa Abadi', // Ini adalah 'nama_pengirim' (hasil populate)
      penerimaId: 'user-penerima-456',
      penerimaTujuan: 'Divisi Keuangan', // Ini adalah 'nama_penerima' (hasil populate)
      // Field yang tidak ada di model Go (berat, divisi, departemen) dihapus.
    ),
    Surat(
      id: 'naskah_id_2',
      nomor: '321/ED/X/2025',
      perihal: 'Surat Edaran Libur Nasional',
      deskripsiSurat: 'Surat edaran resmi mengenai libur nasional',
      sifatSurat: 'Biasa',
      jenisSurat: 'Keluar',
      status: 'Terkirim',
      tanggal: '2025-10-14T14:00:00Z',
      pengirimId: 'user-pengirim-789',
      pengirimAsal: 'Divisi HRD',
      penerimaId: 'all-users',
      penerimaTujuan: 'Semua Divisi',
    ),
  ];

  // Mengubah Stream menjadi data statis
  Stream<List<Surat>> getSuratList() async* {
    yield _dummySuratList;
  }

  Stream<List<Surat>> getKurirSurat() async* {
    yield _dummySuratList.where((s) => 
            s.status == 'Menunggu Kurir' || 
            s.status == 'Dalam Proses' // Diubah dari 'Dalam Pengiriman'
          ).toList();
  }

  Stream<List<Surat>> getSuratByPenerima(String penerimaEmail) async* {
    // Di backend Go, Anda akan membandingkan 'penerima_id'
    // Di sini kita masih pakai 'penerimaTujuan' untuk simulasi
    yield _dummySuratList.where((s) => s.penerimaTujuan == penerimaEmail).toList();
  }
  
  // Metode tambah, ubah, dan hapus dummy
  Future<void> addSurat(Surat surat) async {
    _dummySuratList.add(surat);
  }

  Future<void> updateSuratStatus(String suratId, String newStatus) async {
    // Logika dummy untuk update status
    try {
      final surat = _dummySuratList.firstWhere((s) => s.id == suratId);
      // Ini tidak akan update UI secara otomatis karena Stream-nya
      // tidak reaktif, tapi ini adalah simulasi back-end.
      // surat.status = newStatus; // 'status' adalah final
      print('Status surat $suratId diubah menjadi $newStatus (simulasi)');
    } catch (e) {
      print('Gagal update status surat dummy');
    }
  }

  Future<void> updateSurat(String suratId, Surat surat) async {
    // Tidak melakukan apa-apa
  }
}