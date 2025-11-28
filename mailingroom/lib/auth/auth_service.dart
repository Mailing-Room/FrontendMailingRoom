import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/office.dart'; // ✅ PENTING: Import model Office

class AuthService with ChangeNotifier {
  MyUser? _currentUser;
  MyUser? get currentUser => _currentUser;
  
  bool _isCheckingLogin = true;
  bool get isCheckingLogin => _isCheckingLogin;

  // Base URL ke API Heroku Anda
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
    
    // TODO: Panggil endpoint /verify-token di sini jika ada
    
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

  // --- 🆕 FUNGSI GET OFFICE (DIPERBAIKI SESUAI ROUTES.GO) ---
  Future<List<Office>> getOffices() async {
    // Karena di routes.go Anda: groupes.Get("/office", ...) ada di dalam PublicRoutes
    // Maka URL-nya adalah: .../api/public/office
    final url = Uri.parse('$_baseUrl/public/office'); 
    
    print("Fetching offices from: $url"); // Debug URL

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Menangani struktur JSON backend.
        // Jika response: { "status": "success", "data": [...] } -> ambil 'data'
        // Jika response: [...] -> ambil langsung
        final List<dynamic> officesJson;
        if (data is Map && data.containsKey('data')) {
           officesJson = data['data'];
        } else if (data is List) {
           officesJson = data;
        } else {
           officesJson = [];
        }
        
        return officesJson.map((json) => Office.fromJson(json)).toList();
      } else {
        print("Gagal mengambil data office: ${response.statusCode} (${response.reasonPhrase})");
        return [];
      }
    } catch (e) {
      print("Error fetching offices: $e");
      return []; // Return list kosong agar aplikasi tidak crash
    }
  }

  // --- FUNGSI REGISTER ---
  Future<void> register(String email, String password, String name, String? officeId) async {
    final url = Uri.parse('$_baseUrl/public/register'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name, 
          'office_id': officeId ?? '', // Kirim office_id
          
          'phone': '', 
          'divisi_id': '', 
          'departemen_id': '',
          'sub_direktorat_id': '',
          'jabatan': '',
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registrasi Gagal');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners(); 
  }
}