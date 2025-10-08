// Path: lib/models/surat.dart

class Surat {
  final String? id;
  final String nomor;
  final String perihal;
  final String pengirimAsal;
  final String pengirimDivisi;
  final String pengirimDepartemen;
  final String? penerimaTujuan;
  final String? penerimaDivisi;
  final String? penerimaDepartemen;
  final String jenisSurat;
  final String deskripsiSurat; // Tambahan
  final String sifatSurat; // Tambahan
  final String? fileSuratUrl; // Tambahan
  final String? lpSuratUrl; // Tambahan
  final double? berat; // Tambahan
  final String status;
  final String tanggal;

  Surat({
    this.id,
    required this.nomor,
    required this.perihal,
    required this.pengirimAsal,
    required this.pengirimDivisi,
    required this.pengirimDepartemen,
    this.penerimaTujuan,
    this.penerimaDivisi,
    this.penerimaDepartemen,
    required this.jenisSurat,
    required this.deskripsiSurat,
    required this.sifatSurat,
    this.fileSuratUrl,
    this.lpSuratUrl,
    this.berat,
    required this.status,
    required this.tanggal,
  });

  // Perbarui metode fromMap
  factory Surat.fromMap(Map<String, dynamic> map) {
    return Surat(
      id: map['id'],
      nomor: map['nomor'],
      perihal: map['perihal'],
      pengirimAsal: map['pengirimAsal'],
      pengirimDivisi: map['pengirimDivisi'],
      pengirimDepartemen: map['pengirimDepartemen'],
      penerimaTujuan: map['penerimaTujuan'],
      penerimaDivisi: map['penerimaDivisi'],
      penerimaDepartemen: map['penerimaDepartemen'],
      jenisSurat: map['jenisSurat'],
      deskripsiSurat: map['deskripsiSurat'],
      sifatSurat: map['sifatSurat'],
      fileSuratUrl: map['fileSuratUrl'],
      lpSuratUrl: map['lpSuratUrl'],
      berat: map['berat'],
      status: map['status'],
      tanggal: map['tanggal'],
    );
  }

  // Perbarui metode toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor': nomor,
      'perihal': perihal,
      'pengirimAsal': pengirimAsal,
      'pengirimDivisi': pengirimDivisi,
      'pengirimDepartemen': pengirimDepartemen,
      'penerimaTujuan': penerimaTujuan,
      'penerimaDivisi': penerimaDivisi,
      'penerimaDepartemen': penerimaDepartemen,
      'jenisSurat': jenisSurat,
      'deskripsiSurat': deskripsiSurat,
      'sifatSurat': sifatSurat,
      'fileSuratUrl': fileSuratUrl,
      'lpSuratUrl': lpSuratUrl,
      'berat': berat,
      'status': status,
      'tanggal': tanggal,
    };
  }
}