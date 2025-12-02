class SubDirektorat {
  final String id;
  final String nama;
  final String kode;

  SubDirektorat({
    required this.id,
    required this.nama,
    required this.kode,
  });

  // Factory untuk mengubah JSON dari Backend Go menjadi object Dart
  factory SubDirektorat.fromJson(Map<String, dynamic> json) {
    return SubDirektorat(
      // Sesuaikan key dengan field BSON/JSON di Go
      id: json['_id'] ?? json['id'] ?? '', 
      nama: json['nama_sub_direktorat'] ?? '',
      kode: json['kode_sub_direktorat'] ?? '',
    );
  }
}