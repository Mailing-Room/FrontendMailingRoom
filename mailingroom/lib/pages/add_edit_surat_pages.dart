// Path: lib/pages/add_edit_surat_page.dart

import 'package:flutter/material.dart';
import 'package:mailingroom/models/surat.dart';
import 'package:mailingroom/services/database_service.dart';

class AddEditSuratPage extends StatefulWidget {
  final Surat? surat;

  const AddEditSuratPage({super.key, this.surat});

  @override
  State<AddEditSuratPage> createState() => _AddEditSuratPageState();
}

class _AddEditSuratPageState extends State<AddEditSuratPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomorController = TextEditingController();
  final _perihalController = TextEditingController();
  final _pengirimAsalController = TextEditingController();
  final _penerimaTujuanController = TextEditingController();

  String? _jenisSurat;
  String? _statusSurat;

  @override
  void initState() {
    super.initState();
    if (widget.surat != null) {
      // Mengisi formulir jika dalam mode edit
      _nomorController.text = widget.surat!.nomor;
      _perihalController.text = widget.surat!.perihal;
      _pengirimAsalController.text = widget.surat!.pengirimAsal;
      _penerimaTujuanController.text = widget.surat!.penerimaTujuan ?? '';
      _jenisSurat = widget.surat!.jenisSurat;
      _statusSurat = widget.surat!.status;
    }
  }

  Future<void> _saveSurat() async {
    if (_formKey.currentState!.validate()) {
      final newSurat = Surat(
        nomor: _nomorController.text,
        perihal: _perihalController.text,
        pengirimAsal: _pengirimAsalController.text,
        penerimaTujuan: _penerimaTujuanController.text.isEmpty ? null : _penerimaTujuanController.text,
        jenisSurat: _jenisSurat!,
        status: _statusSurat!,
        tanggal: DateTime.now().toIso8601String(),
      );

      if (widget.surat == null) {
        // Tambah surat baru
        await DatabaseService().addSurat(newSurat);
      } else {
        // Edit surat yang sudah ada
        await DatabaseService().updateSurat(widget.surat!.id!, newSurat);
      }

      Navigator.pop(context); // Kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surat == null ? 'Tambah Surat' : 'Edit Surat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _jenisSurat,
                decoration: const InputDecoration(
                  labelText: 'Jenis Surat',
                  border: OutlineInputBorder(),
                ),
                items: ['Masuk', 'Keluar'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _jenisSurat = value;
                    if (value == 'Masuk') {
                      _statusSurat = 'Menunggu Kurir';
                    } else {
                      _statusSurat = 'Menunggu Kurir';
                    }
                  });
                },
                validator: (value) => value == null ? 'Pilih jenis surat' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomorController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Surat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Nomor surat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _perihalController,
                decoration: const InputDecoration(
                  labelText: 'Perihal',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Perihal tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pengirimAsalController,
                decoration: const InputDecoration(
                  labelText: 'Pengirim Asal',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Pengirim tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _penerimaTujuanController,
                decoration: const InputDecoration(
                  labelText: 'Penerima Tujuan (Email)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Penerima tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSurat,
                child: Text(widget.surat == null ? 'Simpan' : 'Perbarui'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}