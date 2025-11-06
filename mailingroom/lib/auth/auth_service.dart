// lib/auth/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  MyUser? _currentUser;
  MyUser? get currentUser => _currentUser;
  
  bool _isCheckingLogin = true;
  bool get isCheckingLogin => _isCheckingLogin;

  // URL base diubah ke /api
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
    
    // TODO: Idealnya, panggil endpoint /verify-token di sini
    
    _isCheckingLogin = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // PERBAIKAN: Endpoint diubah ke /public/login
    final url = Uri.parse('$_baseUrl/public/login'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = MyUser.fromJson(data['user']);
        _token = data['token'];
        if (_token == null) throw Exception('Token tidak ditemukan');
        await _storage.write(key: 'auth_token', value: _token);
        notifyListeners(); 
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // PERBAIKAN: Endpoint register juga disesuaikan
  Future<void> register(String email, String password, String role, String name, String phone) async {
    // Sesuaikan dengan endpoint register dari backend Anda
    final url = Uri.parse('$_baseUrl/admin/inputuser'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // TODO: Backend mungkin butuh 'Authorization' header jika ini rute admin
        body: jsonEncode({
          'email': email,
          'password': password,
          'role_id': role,
          'name': name, 
          'phone': phone, 
          'divisi_id': '', 
          'office_id': '',
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
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners(); 
  }
}