// Path: lib/auth/auth_service.dart

import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService {
  // Metode login dummy
  Future<MyUser?> signInWithEmailAndPassword(String email, String password) async {
    // Simulasi login sukses
    if (email == 'pengirim@mailingroom.com' && password == 'password123') {
      return MyUser(uid: 'pengirim_id_dummy', email: 'pengirim@mailingroom.com', role: 'pengirim');
    }
    return null;
  }

  // Metode registrasi dummy
  Future<MyUser?> registerWithEmailAndPassword(String email, String password, String role) async {
    return MyUser(uid: 'new_user_id', email: email, role: role);
  }

  // Metode untuk sign out (keluar)
  Future<void> signOut() async {
    // Tidak melakukan apa-apa karena tidak ada otentikasi
    return;
  }
}