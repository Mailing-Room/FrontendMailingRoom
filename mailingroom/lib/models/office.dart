class Office {
  final String id;
  final String namaOffice;
  final String alamat;
  final String kota;
  final String kodePos;
  final String noTelp;

  Office({
    required this.id,
    required this.namaOffice,
    required this.alamat,
    required this.kota,
    required this.kodePos,
    required this.noTelp,
  });

  // Factory untuk mengubah JSON dari Backend Go menjadi object Dart
  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      // Sesuaikan key ini dengan output JSON dari Go (bson tag atau json tag di struct model Go)
      // Biasanya Go Fiber + MongoDB mengembalikan '_id' sebagai string hex jika menggunakan primitive.ObjectID
      id: json['_id'] ?? json['id'] ?? '', 
      namaOffice: json['nama_office'] ?? '',
      alamat: json['alamat'] ?? '',
      kota: json['kota'] ?? '',
      kodePos: json['kode_pos'] ?? '',
      noTelp: json['no_telp'] ?? '',
    );
  }
}