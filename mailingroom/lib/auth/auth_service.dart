// lib/auth/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final StreamController<MyUser?> _userController = StreamController<MyUser?>.broadcast();
  Stream<MyUser?> get userStream => _userController.stream;
  MyUser? _currentUser;
  
  final String _baseUrl = 'https://mailingroom-db0c7a47e986.herokuapp.com';
  final _storage = const FlutterSecureStorage();
  String? _token;

  AuthService() {
    // INI ADALAH KUNCI PERBAIKAN LOADING:
    // Langsung kirim status 'null' (belum login) saat aplikasi dimulai.
    _userController.add(null);
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
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
        _userController.add(_currentUser);
        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> register(String email, String password, String role) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role_id': role,
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
    _userController.add(null);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _userController.close();
    super.dispose();
  }
}