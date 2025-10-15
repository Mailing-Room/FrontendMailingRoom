// lib/auth/auth_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart'; // Pastikan nama class di sini adalah MyUser

class AuthService with ChangeNotifier {
  final StreamController<MyUser?> _userController = StreamController<MyUser?>.broadcast();
  Stream<MyUser?> get userStream => _userController.stream;
  MyUser? _currentUser;

  // ✅ CONSTRUCTOR YANG HILANG. TAMBAHKAN INI.
  AuthService() {
    // Saat AuthService pertama kali dibuat, langsung kirim status awal
    // bahwa tidak ada user yang login (null). Ini akan menghentikan loading.
    _userController.add(null);
  }

  // Metode login dummy
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'kurir@pos.id') {
      _currentUser = MyUser(uid: 'kurir_id_dummy', email: email, role: 'kurir');
    } else if (email == 'pengirim@pos.id') {
      _currentUser = MyUser(uid: 'pengirim_id_dummy', email: email, role: 'pengirim');
    } else {
      throw Exception('Email atau password salah');
    }
    
    _userController.add(_currentUser);
    notifyListeners();
  }

  Future<MyUser?> registerWithEmailAndPassword(String email, String password, String role) async {
    await Future.delayed(const Duration(seconds: 1));
    return MyUser(uid: 'new_user_id_${DateTime.now().millisecondsSinceEpoch}', email: email, role: role);
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
    notifyListeners();
  }

  @override
  void dispose() {
    _userController.close();
    super.dispose();
  }
}