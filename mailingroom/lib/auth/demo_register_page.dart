import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import '../models/office.dart';

class DemoRegisterPage extends StatefulWidget {
  const DemoRegisterPage({super.key});

  @override
  State<DemoRegisterPage> createState() =>
      _DemoRegisterPageState();
}

class _DemoRegisterPageState
    extends State<DemoRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Office> _officeList = [];

  String? _selectedOfficeId;

  bool _isLoadingOffices = true;
  bool _isLoading = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOffices();
  }

  Future<void> _fetchOffices() async {
    setState(() {
      _isLoadingOffices = true;
    });

    try {
      final authService =
          Provider.of<AuthService>(
        context,
        listen: false,
      );

      final offices =
          await authService.getOffices();

      if (mounted) {
        setState(() {
          _officeList = offices;
          _isLoadingOffices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _officeList = [];
          _isLoadingOffices = false;
        });
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService =
          Provider.of<AuthService>(
        context,
        listen: false,
      );

      await authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        officeId: _selectedOfficeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi berhasil! Silakan login.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String message = e.toString();

        if (message.startsWith('Exception: ')) {
          message = message.substring(11);
        }

        setState(() {
          _errorMessage = message;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon:
                        Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }

                    return null;
                  },
                  textCapitalization:
                      TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                _buildOfficeDropdown(),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }

                    if (!value.endsWith('@gmail.com')) {
                      return 'Email harus menggunakan @gmail.com';
                    }

                    return null;
                  },
                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ElevatedButton(
                  onPressed:
                      _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeDropdown() {
    if (_isLoadingOffices) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_officeList.isEmpty) {
      return InkWell(
        onTap: _fetchOffices,
        child: InputDecorator(
          decoration:
              const InputDecoration(
            labelText:
                'Pilih Kantor / Office',
            prefixIcon: Icon(
              Icons.location_city,
              color: Colors.red,
            ),
            border: OutlineInputBorder(),
            errorText:
                'Gagal memuat data. Ketuk untuk ulangi.',
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Data tidak ditemukan',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              Icon(
                Icons.refresh,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedOfficeId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Pilih Kantor / Office',
        prefixIcon:
            Icon(Icons.location_city),
        border: OutlineInputBorder(),
      ),
      hint: const Text(
        'Pilih lokasi kantor Anda',
      ),
      items: _officeList.map(
        (Office office) {
          return DropdownMenuItem<String>(
            value: office.id,
            child: Text(
              '${office.namaOffice} (${office.kota})',
              overflow:
                  TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedOfficeId = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Harap pilih kantor';
        }

        return null;
      },
    );
  }
}