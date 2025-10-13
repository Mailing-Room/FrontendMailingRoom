import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // ✅ Tambahkan ini
import '../models/surat.dart';
// import '../services/database_service.dart';

class AddEditSuratPage extends StatefulWidget {
  final Surat? surat;
  final bool isEdit;

  const AddEditSuratPage({super.key, this.surat, this.isEdit = false});

  @override
  State<AddEditSuratPage> createState() => _AddEditSuratPageState();
}

class _AddEditSuratPageState extends State<AddEditSuratPage> {
  // Warna khas Pos Indonesia
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);

  final _formKey = GlobalKey<FormState>();

  File? _fileSurat;
  File? _fileLP;

  late TextEditingController nomorController;
  late TextEditingController perihalController;
  late TextEditingController deskripsiController;
  late TextEditingController penerimaController;
  late TextEditingController pengirimAsalController;
  late TextEditingController pengirimDivisiController;
  late TextEditingController pengirimDepartemenController;
  late TextEditingController penerimaDivisiController;
  late TextEditingController penerimaDepartemenController;
  late TextEditingController beratController;

  String? _selectedJenisSurat;
  String? _selectedSifatSurat;
  final List<String> _jenisSuratOptions = ['Internal', 'Eksternal', 'Rahasia'];
  final List<String> _sifatSuratOptions = ['Biasa', 'Penting', 'Segera'];

  @override
  void initState() {
    super.initState();
    nomorController = TextEditingController(text: widget.surat?.nomor ?? '');
    perihalController =
        TextEditingController(text: widget.surat?.perihal ?? '');
    deskripsiController =
        TextEditingController(text: widget.surat?.deskripsiSurat ?? '');
    penerimaController =
        TextEditingController(text: widget.surat?.penerimaTujuan ?? '');
    pengirimAsalController =
        TextEditingController(text: widget.surat?.pengirimAsal ?? '');
    pengirimDivisiController =
        TextEditingController(text: widget.surat?.pengirimDivisi ?? '');
    pengirimDepartemenController =
        TextEditingController(text: widget.surat?.pengirimDepartemen ?? '');
    penerimaDivisiController =
        TextEditingController(text: widget.surat?.penerimaDivisi ?? '');
    penerimaDepartemenController =
        TextEditingController(text: widget.surat?.penerimaDepartemen ?? '');
    beratController =
        TextEditingController(text: widget.surat?.berat?.toString() ?? '');

    if (widget.isEdit && widget.surat != null) {
      _selectedJenisSurat = widget.surat!.jenisSurat;
      _selectedSifatSurat = widget.surat!.sifatSurat;
    }
  }

  @override
  void dispose() {
    nomorController.dispose();
    perihalController.dispose();
    deskripsiController.dispose();
    penerimaController.dispose();
    pengirimAsalController.dispose();
    pengirimDivisiController.dispose();
    pengirimDepartemenController.dispose();
    penerimaDivisiController.dispose();
    penerimaDepartemenController.dispose();
    beratController.dispose();
    super.dispose();
  }

  Future<void> _pickFileSurat() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileSurat = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickFileLP() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileLP = File(result.files.single.path!);
      });
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fileSurat == null || _fileLP == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda wajib melampirkan File Surat dan File LP!')),
      );
      return;
    }

    final suratData = Surat(
      id: widget.isEdit ? widget.surat!.id : null,
      nomor: nomorController.text,
      perihal: perihalController.text,
      deskripsiSurat: deskripsiController.text,
      penerimaTujuan: penerimaController.text,
      pengirimAsal: pengirimAsalController.text,
      pengirimDivisi: pengirimDivisiController.text,
      pengirimDepartemen: pengirimDepartemenController.text,
      penerimaDivisi: penerimaDivisiController.text,
      penerimaDepartemen: penerimaDepartemenController.text,
      jenisSurat: _selectedJenisSurat!,
      sifatSurat: _selectedSifatSurat!,
      berat: double.tryParse(beratController.text) ?? 0.0,
      status: widget.isEdit ? widget.surat!.status : 'Baru',
      tanggal: widget.isEdit
          ? widget.surat!.tanggal
          : DateTime.now().toIso8601String(),
    );

    // TODO: Upload ke Firebase Storage, simpan ke database nanti

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.isEdit
                ? 'Surat berhasil diperbarui!'
                : 'Surat berhasil disimpan!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: posBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Surat' : 'Tambah Surat'),
        backgroundColor: posBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Informasi Utama'),
              TextFormField(
                controller: nomorController,
                decoration: const InputDecoration(labelText: 'Nomor Surat'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: perihalController,
                decoration: const InputDecoration(labelText: 'Perihal'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi Surat'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              _buildSectionTitle('Detail Surat & Lampiran'),
              DropdownButtonFormField<String>(
                value: _selectedJenisSurat,
                hint: const Text('Pilih Jenis Surat'),
                items: _jenisSuratOptions
                    .map((e) =>
                        DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedJenisSurat = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSifatSurat,
                hint: const Text('Pilih Sifat Surat'),
                items: _sifatSuratOptions
                    .map((e) =>
                        DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSifatSurat = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: beratController,
                decoration: const InputDecoration(labelText: 'Berat (gram)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickFileSurat,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Lampirkan File Surat (Wajib)'),
                  ),
                  if (_fileSurat != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'File: ${_fileSurat!.path.split('/').last}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickFileLP,
                    icon: const Icon(Icons.post_add),
                    label: const Text('Lampirkan File LP (Wajib)'),
                  ),
                  if (_fileLP != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'File: ${_fileLP!.path.split('/').last}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                ],
              ),
              _buildSectionTitle('Informasi Pengirim'),
              TextFormField(
                controller: pengirimAsalController,
                decoration: const InputDecoration(labelText: 'Asal Pengirim'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pengirimDivisiController,
                decoration: const InputDecoration(labelText: 'Divisi Pengirim'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pengirimDepartemenController,
                decoration:
                    const InputDecoration(labelText: 'Departemen Pengirim'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              _buildSectionTitle('Informasi Penerima'),
              TextFormField(
                controller: penerimaController,
                decoration: const InputDecoration(labelText: 'Tujuan Penerima'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: penerimaDivisiController,
                decoration: const InputDecoration(labelText: 'Divisi Penerima'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: penerimaDepartemenController,
                decoration:
                    const InputDecoration(labelText: 'Departemen Penerima'),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label:
                    Text(widget.isEdit ? 'Simpan Perubahan' : 'Simpan Surat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: posOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
