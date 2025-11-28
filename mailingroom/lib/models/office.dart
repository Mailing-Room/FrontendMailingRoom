class Office {
  final String id;
  final String namaOffice;
  final String kota;

  Office({
    required this.id,
    required this.namaOffice,
    required this.kota,
  });

  // Factory untuk mengubah JSON dari Backend Go menjadi object Dart
  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      // Sesuaikan key ini dengan JSON response dari backend Anda
      // Biasanya '_id' jika dari MongoDB langsung, atau 'id' jika sudah diformat
      id: json['_id'] ?? json['id'] ?? '', 
      namaOffice: json['nama_office'] ?? '',
      kota: json['kota'] ?? '',
    );
  }
}