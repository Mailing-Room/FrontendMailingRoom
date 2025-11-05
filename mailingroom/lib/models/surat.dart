class Surat {
  final String id;
  final String nomor;
  final String perihal;
  final String jenisSurat;
  final String sifatSurat;
  final String? kategoriId;
  final String? deskripsiSurat;
  final String? fileSuratUrl;
  final String status;
  final String pengirimId;
  final String? penerimaId;
  final String? kurirId;
  final String tanggal; // Akan kita map dari CreatedAt

  // Ini adalah data yang tidak ada di model Go, tapi dibutuhkan oleh UI.
  // Data ini perlu di-POPULATE oleh backend Go Anda.
  final String pengirimAsal;
  final String? penerimaTujuan;

  Surat({
    required this.id,
    required this.nomor,
    required this.perihal,
    required this.jenisSurat,
    required this.sifatSurat,
    this.kategoriId,
    this.deskripsiSurat,
    this.fileSuratUrl,
    required this.status,
    required this.pengirimId,
    this.penerimaId,
    this.kurirId,
    required this.tanggal,
    
    // Data tambahan
    required this.pengirimAsal,
    this.penerimaTujuan,
  });

  // Fungsi ini mengubah data JSON Naskah dari server Go menjadi object Surat
  factory Surat.fromJson(Map<String, dynamic> json) {
    return Surat(
      id: json['naskah_id'],
      nomor: json['noSurat'],
      perihal: json['judul'],
      jenisSurat: json['jenisNaskah'],
      sifatSurat: json['sifatNaskah'],
      kategoriId: json['kategori_id'],
      deskripsiSurat: json['deskripsi'],
      fileSuratUrl: json['filePath'],
      status: json['status'],
      pengirimId: json['pengirim_id'],
      penerimaId: json['penerima_id'],
      kurirId: json['kurir_id'],
      tanggal: json['createdAt'], // Map 'tanggal' ke 'createdAt'

      // ==========================================================
      // PENTING: Backend Go Anda harus mengirim data ini juga.
      // Jika 'pengirim_id' = 'user-123', Go harus mencari 'user-123'
      // dan mengirim namanya sebagai 'nama_pengirim'
      // ==========================================================
      pengirimAsal: json['nama_pengirim'] ?? 'Pengirim Tidak Dikenal',
      penerimaTujuan: json['nama_penerima'] ?? '-',
    );
  }
}