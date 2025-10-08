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
  final _deskripsiController = TextEditingController(); // Tambahan
  final _pengirimAsalController = TextEditingController();
  final _pengirimDivisiController = TextEditingController();
  final _pengirimDepartemenController = TextEditingController();
  final _penerimaTujuanController = TextEditingController();
  final _penerimaDivisiController = TextEditingController();
  final _penerimaDepartemenController = TextEditingController();
  final _beratController = TextEditingController(); // Tambahan

  String? _jenisSurat;
  String? _sifatSurat; // Tambahan
  String? _statusSurat;

  @override
  void initState() {
    super.initState();
    if (widget.surat != null) {
      _nomorController.text = widget.surat!.nomor;
      _perihalController.text = widget.surat!.perihal;
      _deskripsiController.text = widget.surat!.deskripsiSurat;
      _pengirimAsalController.text = widget.surat!.pengirimAsal;
      _pengirimDivisiController.text = widget.surat!.pengirimDivisi;
      _pengirimDepartemenController.text = widget.surat!.pengirimDepartemen;
      _penerimaTujuanController.text = widget.surat!.penerimaTujuan ?? '';
      _penerimaDivisiController.text = widget.surat!.penerimaDivisi ?? '';
      _penerimaDepartemenController.text = widget.surat!.penerimaDepartemen ?? '';
      _beratController.text = widget.surat!.berat?.toString() ?? '';
      _jenisSurat = widget.surat!.jenisSurat;
      _sifatSurat = widget.surat!.sifatSurat;
      _statusSurat = widget.surat!.status;
    }
  }

  Future<void> _saveSurat() async {
    if (_formKey.currentState!.validate()) {
      final newSurat = Surat(
        nomor: _nomorController.text,
        perihal: _perihalController.text,
        deskripsiSurat: _deskripsiController.text,
        sifatSurat: _sifatSurat!,
        pengirimAsal: _pengirimAsalController.text,
        pengirimDivisi: _pengirimDivisiController.text,
        pengirimDepartemen: _pengirimDepartemenController.text,
        penerimaTujuan: _penerimaTujuanController.text.isEmpty ? null : _penerimaTujuanController.text,
        penerimaDivisi: _penerimaDivisiController.text.isEmpty ? null : _penerimaDivisiController.text,
        penerimaDepartemen: _penerimaDepartemenController.text.isEmpty ? null : _penerimaDepartemenController.text,
        berat: double.tryParse(_beratController.text),
        jenisSurat: _jenisSurat!,
        status: _statusSurat!,
        tanggal: DateTime.now().toIso8601String(),
      );

      if (widget.surat == null) {
        await DatabaseService().addSurat(newSurat);
      } else {
        await DatabaseService().updateSurat(widget.surat!.id!, newSurat);
      }
      Navigator.pop(context);
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
              _buildSectionHeader('Informasi Surat'),
              DropdownButtonFormField<String>(
                value: _jenisSurat,
                decoration: const InputDecoration(labelText: 'Jenis Kiriman', border: OutlineInputBorder()),
                items: ['Surat', 'Paket'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) {
                  setState(() {
                    _jenisSurat = value;
                    if (value == 'Surat') {
                      _statusSurat = 'Menunggu Kurir';
                    } else {
                      _statusSurat = 'Menunggu Kurir';
                    }
                  });
                },
                validator: (value) => value == null ? 'Pilih jenis kiriman' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomorController,
                decoration: const InputDecoration(labelText: 'Nomor Surat', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nomor surat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _perihalController,
                decoration: const InputDecoration(labelText: 'Perihal', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Perihal tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi Kiriman', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sifatSurat,
                decoration: const InputDecoration(labelText: 'Sifat Surat', border: OutlineInputBorder()),
                items: ['Biasa', 'Penting', 'Rahasia'].map((sifat) => DropdownMenuItem(value: sifat, child: Text(sifat))).toList(),
                onChanged: (value) {
                  setState(() {
                    _sifatSurat = value;
                  });
                },
                validator: (value) => value == null ? 'Pilih sifat surat' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _beratController,
                decoration: const InputDecoration(labelText: 'Berat (gram)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Berat tidak boleh kosong' : null,
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Upload Dokumen'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementasi logika upload file
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File Surat'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementasi logika upload LP
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload LP Surat'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Detail Pengirim'),
              TextFormField(
                controller: _pengirimAsalController,
                decoration: const InputDecoration(labelText: 'Nama Pengirim', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nama pengirim tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pengirimDivisiController,
                decoration: const InputDecoration(labelText: 'Divisi Pengirim', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Divisi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pengirimDepartemenController,
                decoration: const InputDecoration(labelText: 'Departemen Pengirim', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Departemen tidak boleh kosong' : null,
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('Detail Penerima'),
              TextFormField(
                controller: _penerimaTujuanController,
                decoration: const InputDecoration(labelText: 'Nama Penerima', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nama penerima tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _penerimaDivisiController,
                decoration: const InputDecoration(labelText: 'Divisi Penerima', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _penerimaDepartemenController,
                decoration: const InputDecoration(labelText: 'Departemen Penerima', border: OutlineInputBorder()),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}