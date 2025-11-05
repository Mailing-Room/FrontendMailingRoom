class MyUser {
  final String uid;
  final String email;
  final String role;
  final String nama;
  final String? officeId;
  final String? departemenId;
  final String? divisiId;
  final String? jabatan;
  final String? phone;
  final String? createdAt; // Opsional jika perlu

  MyUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.nama,
    this.officeId,
    this.departemenId,
    this.divisiId,
    this.jabatan,
    this.phone,
    this.createdAt,
  });

  // Fungsi ini mengubah data JSON dari server Go menjadi object MyUser
  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      uid: json['user_id'],      // Cocokkan dengan json:"user_id"
      email: json['email'],
      role: json['role_id'],      // Cocokkan dengan json:"role_id"
      nama: json['name'],         // Cocokkan dengan json:"name"
      officeId: json['office_id'],
      departemenId: json['departemen_id'],
      divisiId: json['divisi_id'],
      jabatan: json['jabatan'],
      phone: json['phone'],
      createdAt: json['createdAt'],
    );
  }
}