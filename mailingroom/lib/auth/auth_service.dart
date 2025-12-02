import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/office.dart'; 
import '../models/subdirektorat.dart'; 

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
        if (errorMessage.contains("invalid password")) errorMessage = "Password salah.";
        else if (errorMessage.contains("failed to login user")) errorMessage = "Email tidak terdaftar.";
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // --- READ: Get All Users ---
  Future<List<MyUser>> getAllUsers() async {
    final url = Uri.parse('$_baseUrl/user/getallusers'); 
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> usersJson = (data is Map && data.containsKey('users')) 
            ? data['users'] 
            : (data is List ? data : []);
        
        return usersJson.map((json) => MyUser.fromJson(json)).toList();
      } else {
        print("Gagal mengambil users: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // --- CREATE: Add User ---
  Future<void> addUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? officeId,
    String? subDirektoratId,
  }) async {
    // Menggunakan endpoint admin untuk input user
    final url = Uri.parse('$_baseUrl/admin/inputuser');
    final token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role_id': role, // 'admin', 'kurir', 'user', 'penerima'
          'office_id': officeId ?? '',
          'sub_direktorat_id': subDirektoratId ?? '',
          'phone': '',
          'divisi_id': '',
          'departemen_id': '',
          'jabatan': '',
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menambah user');
      }
      notifyListeners(); // Refresh UI jika perlu
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- UPDATE: Edit User ---
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/user/updateuser/$uid');
    final token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengupdate user');
      }
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- DELETE: Delete User ---
  Future<void> deleteUser(String uid) async {
    final url = Uri.parse('$_baseUrl/user/deleteuserbyid/$uid');
    final token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menghapus user');
      }
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- Helper Functions untuk Dropdown ---
  Future<List<Office>> getOffices() async {
    final url = Uri.parse('$_baseUrl/public/office'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> listJson = (data is Map && data.containsKey('data')) 
            ? data['data'] ?? [] 
            : (data is List ? data : []);
        return listJson.map((json) => Office.fromJson(json)).toList();
      } else { return []; }
    } catch (e) { return []; }
  }

  Future<List<SubDirektorat>> getSubDirektorats() async {
    final url = Uri.parse('$_baseUrl/public/subdirektorat'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> listJson = (data is Map && data.containsKey('data')) 
            ? data['data'] ?? [] 
            : (data is List ? data : []);
        return listJson.map((json) => SubDirektorat.fromJson(json)).toList();
      } else { return []; }
    } catch (e) { return []; }
  }

  // Fungsi register publik (tanpa token) - tetap dipertahankan untuk RegisterPage
  Future<void> register({
    required String email, 
    required String password, 
    required String name, 
    String? officeId,
    String? subDirektoratId,
  }) async {
    final url = Uri.parse('$_baseUrl/public/register'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name, 
          'office_id': officeId ?? '', 
          'sub_direktorat_id': subDirektoratId ?? '', 
          'phone': '', 
          'divisi_id': '', 
          'departemen_id': '',
          'jabatan': '',
        }),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registrasi Gagal');
      }
    } catch (e) { throw Exception(e.toString().replaceAll("Exception: ", "")); }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners(); 
  }
}