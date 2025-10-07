// Path: lib/models/user.dart

class MyUser {
  final String uid;
  final String email;
  final String role; // 'pengirim', 'kurir', 'penerima'

  MyUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  // Factory constructor untuk membuat objek MyUser dari Map (data Firestore)
  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }

  // Metode untuk mengkonversi objek MyUser menjadi Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
    };
  }
}