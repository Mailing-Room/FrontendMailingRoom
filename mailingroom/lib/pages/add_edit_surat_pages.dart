// Path: lib/pages/add_edit_surat_page.dart
import 'package:flutter/material.dart';
import '../models/surat.dart';

class AddEditSuratPage extends StatefulWidget {
  final Surat? surat;
  final bool isEdit;

  const AddEditSuratPage({super.key, this.surat, this.isEdit = false});

  @override
  State<AddEditSuratPage> createState() => _AddEditSuratPageState();
}

class _AddEditSuratPageState extends State<AddEditSuratPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomorController;
  late TextEditingController perihalController;
  late TextEditingController deskripsiController;
  late TextEditingController penerimaController;

  @override
  void initState() {
    super.initState();
    nomorController = TextEditingController(text: widget.surat?.nomor ?? '');
    perihalController = TextEditingController(text: widget.surat?.perihal ?? '');
    deskripsiController = TextEditingController(text: widget.surat?.deskripsiSurat ?? '');
    penerimaController = TextEditingController(text: widget.surat?.penerimaTujuan ?? '');
  }

  @override
  void dispose() {
    nomorController.dispose();
    perihalController.dispose();
    deskripsiController.dispose();
    penerimaController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? 'Surat berhasil diperbarui!' : 'Surat berhasil ditambahkan!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade600;
    final Color accentColor = Colors.orange.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Surat' : 'Tambah Surat'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomorController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Surat',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nomor surat wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: perihalController,
                decoration: const InputDecoration(
                  labelText: 'Perihal',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Perihal wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Surat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: penerimaController,
                decoration: const InputDecoration(
                  labelText: 'Penerima Tujuan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label: Text(widget.isEdit ? 'Simpan Perubahan' : 'Tambah Surat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
