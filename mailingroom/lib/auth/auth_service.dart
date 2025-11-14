import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart'; // Pastikan Anda memiliki file models/user.dart

// Asumsi model MyUser sederhana
// class MyUser {
//   final String userId;
//   final String name;
//   final String email;
//   final String roleId;
//   MyUser({required this.userId, required this.name, required this.email, required this.roleId});
//
//   factory MyUser.fromJson(Map<String, dynamic> json) {
//     return MyUser(
//       userId: json['user_id'] ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       roleId: json['role_id'] ?? '',
//     );
//   }
// }

class AuthService with ChangeNotifier {
  MyUser? _currentUser;
  MyUser? get currentUser => _currentUser;
  
  bool _isCheckingLogin = true;
  bool get isCheckingLogin => _isCheckingLogin;

  final String _baseUrl = 'https://mailingroom-db0c7a47e986.herokuapp.com/api'; 
  final _storage = const FlutterSecureStorage();
  String? _token;

  AuthService() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _token = await _storage.read(key: 'auth_token');
    
    if (_token == null) {
      _isCheckingLogin = false;
      notifyListeners();
      return;
    }
    
    // TODO: Panggil endpoint /verify-token di sini untuk validasi
    // dan mengambil data user berdasarkan token yang tersimpan.
    // Jika berhasil, set _currentUser.
    
    _isCheckingLogin = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/public/login'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Pastikan 'user' ada di response
        if (data['user'] == null) {
          throw Exception('Data user tidak ditemukan di response login.');
        }
        
        _currentUser = MyUser.fromJson(data['user']); 
        _token = data['token'];
        
        if (_token == null) throw Exception('Token tidak ditemukan');
        
        await _storage.write(key: 'auth_token', value: _token);
        notifyListeners(); 
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Login Gagal';
        
        // Terjemahkan error dari backend Go
        if (errorMessage.contains("invalid password")) {
          errorMessage = "Password yang Anda masukkan salah.";
        } else if (errorMessage.contains("failed to login user")) {
           errorMessage = "Email tidak terdaftar.";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // --- FUNGSI REGISTER YANG DIPERBARUI ---
  Future<void> register(String email, String password, String name, String phone) async {
    // Endpoint diubah ke /public/register sesuai controller Go Anda
    final url = Uri.parse('$_baseUrl/public/register'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // 'role_id' dihapus, karena backend (RegisterUser) sudah mengaturnya ke "user"
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name, 
          'phone': phone, 
          'divisi_id': '', // Tetap kirim string kosong jika backend mengharapkannya
          'office_id': '',
          'departemen_id': '',
          'sub_direktorat_id': '',
          'jabatan': '',
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        // Lempar pesan error spesifik dari backend
        throw Exception(errorData['message'] ?? 'Registrasi Gagal');
      }
      // Registrasi berhasil, tidak ada data yang perlu diproses di sini
    } catch (e) {
      // Format ulang errornya agar lebih bersih
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
  // --- AKHIR FUNGSI REGISTER ---

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners(); 
  }
}