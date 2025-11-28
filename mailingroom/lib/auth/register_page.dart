import 'package:flutter/material.dart';
import 'package:mailingroom/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/office.dart'; // ✅ Pastikan import model Office ini benar

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- State untuk Office ---
  List<Office> _officeList = [];
  String? _selectedOfficeId;
  bool _isLoadingOffices = true;
  // --------------------------

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data office saat halaman dibuka
    _fetchOffices();
  }

  // Fungsi mengambil data office dari backend via AuthService
  Future<void> _fetchOffices() async {
    setState(() {
      _isLoadingOffices = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final offices = await authService.getOffices();
      
      if (mounted) {
        setState(() {
          _officeList = offices;
          _isLoadingOffices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _officeList = []; // Pastikan list kosong jika error
          _isLoadingOffices = false;
          // Opsional: Tampilkan snackbar atau pesan error jika gagal load office
          print("Error loading offices: $e");
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Tutup keyboard
    FocusScope.of(context).unfocus();
    
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Panggil register dengan officeId yang dipilih
      await authService.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _selectedOfficeId, // ✅ Kirim ID office yang dipilih
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
          String message = e.toString();
          if (message.startsWith('Exception: ')) {
            message = message.substring('Exception: '.length);
          }
          _errorMessage = message;
        });
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                // Form Nama
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) => (value == null || value.isEmpty) ? 'Nama tidak boleh kosong' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                
                // --- DROPDOWN OFFICE BARU (DENGAN PENANGANAN ERROR) ---
                _isLoadingOffices 
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      ),
                    ))
                  : _officeList.isEmpty
                      // Jika data kosong/gagal load, tampilkan tombol refresh
                      ? InkWell(
                          onTap: _fetchOffices,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Pilih Kantor / Office',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                              errorText: 'Gagal memuat data. Ketuk untuk ulangi.',
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Data tidak ditemukan"),
                                Icon(Icons.refresh, color: Colors.orange),
                              ],
                            ),
                          ),
                        )
                      // Jika data ada, tampilkan dropdown normal
                      : DropdownButtonFormField<String>(
                          value: _selectedOfficeId,
                          isExpanded: true, // Agar teks panjang tidak overflow
                          decoration: const InputDecoration(
                            labelText: 'Pilih Kantor / Office',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Pilih lokasi kantor Anda'),
                          items: _officeList.map((Office office) {
                            return DropdownMenuItem<String>(
                              value: office.id, // Value yang disimpan adalah ID
                              child: Text(
                                "${office.namaOffice} (${office.kota})", // Tampilan Nama + Kota
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedOfficeId = newValue;
                            });
                          },
                          validator: (value) => (value == null) ? 'Harap pilih kantor' : null,
                        ),
                // -----------------------------

                const SizedBox(height: 16),
                
                // Form Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                    if (!value.endsWith('@gmail.com')) return 'Email harus menggunakan @gmail.com';
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Form Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (value) => (value == null || value.length < 6) ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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