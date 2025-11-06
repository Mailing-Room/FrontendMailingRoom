// lib/auth/register_page.dart

import 'package:flutter/material.dart';
import 'package:mailingroom/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  // ✅ Tambahkan controller baru
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    
    if (_selectedRole == null) {
      setState(() { _errorMessage = 'Harap pilih peran pengguna.'; });
      return;
    }
    
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // ✅ Panggil fungsi register dengan parameter baru
      await authService.register(
        _emailController.text,
        _passwordController.text,
        _selectedRole!,
        _nameController.text, // Kirim nama
        _phoneController.text, // Kirim telepon
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke halaman login
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Registrasi Akun'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ Tambahkan Form Nama
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                
                // ✅ Tambahkan Form Telepon
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Telepon tidak boleh kosong' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Email tidak boleh kosong' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (value) => (value == null || value.length < 6) ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Peran',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: ['pengirim', 'kurir', 'admin'] 
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) => (value == null) ? 'Pilih peran pengguna' : null,
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _register,
                  child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
