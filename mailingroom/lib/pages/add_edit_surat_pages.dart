import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // Menggunakan Google Fonts

import '../models/surat.dart';
// import '../services/database_service.dart'; // Uncomment jika sudah siap integrasi database

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
  final Color lightGrey = const Color(0xFFF0F0F0); // Warna abu-abu terang untuk background input

  final _formKey = GlobalKey<FormState>();

  File? _fileSurat;
  File? _fileLP;
  bool _isLoading = false; // State untuk indikator loading

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
    if (_isLoading) return; // Mencegah multiple tap saat loading

    bool isJenisValid = _selectedJenisSurat != null;
    bool isSifatValid = _selectedSifatSurat != null;

    if (!_formKey.currentState!.validate() || !isJenisValid || !isSifatValid) {
        if (!isJenisValid || !isSifatValid) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Harap lengkapi semua pilihan jenis dan sifat surat!')),
            );
        }
        return;
    }

    if (_fileSurat == null || _fileLP == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda wajib melampirkan File Surat dan File LP!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading saat proses penyimpanan
    });

    try {
      final suratData = Surat(
        id: widget.isEdit ? (widget.surat!.id ?? '') : '',
        nomor: nomorController.text,
        perihal: perihalController.text,
        deskripsiSurat: deskripsiController.text,
        penerimaTujuan: penerimaController.text,
        pengirimAsal: pengirimAsalController.text,
        pengirimId: widget.isEdit ? widget.surat!.pengirimId : 'default_id', // Add this line
        jenisSurat: _selectedJenisSurat!,
        sifatSurat: _selectedSifatSurat!,
        status: widget.isEdit ? widget.surat!.status : 'Baru',
        tanggal: widget.isEdit
            ? widget.surat!.tanggal
            : DateTime.now().toIso8601String(),
      );

      // TODO: Implementasi logika upload ke Firebase Storage dan simpan ke database
      // Contoh: await DatabaseService().addOrUpdateSurat(suratData);
      // Untuk simulasi, kita pakai delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Surat berhasil diperbarui!'
                  : 'Surat berhasil disimpan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan surat: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Nonaktifkan loading setelah proses selesai
        });
      }
    }
  }

  // Widget helper untuk judul seksi
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: posOrange, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
                fontSize: 19, fontWeight: FontWeight.bold, color: posBlue),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk input field agar lebih rapi
  Widget _buildTextField({
      required TextEditingController controller,
      required String label,
      int maxLines = 1,
      TextInputType? keyboardType,
      bool isRequired = true,
  }) {
      return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: posBlue.withOpacity(0.8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Border lebih membulat
                    borderSide: BorderSide(color: posBlue.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: posBlue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: posOrange, width: 2), // Warna fokus oranye
                  ),
                  filled: true,
                  fillColor: lightGrey, // Warna background input
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: isRequired ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
          ),
      );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background keseluruhan
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Surat' : 'Buat Surat Baru',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: posBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: posOrange),
                  const SizedBox(height: 16),
                  Text('Menyimpan data surat...',
                    style: GoogleFonts.poppins(fontSize: 16, color: posBlue)),
                ],
              ),
            )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              // ================= BAGIAN 1: DATA PENGIRIM =================
              _buildSectionTitle('Data Pengirim', Icons.person_outline),
              _buildTextField(
                controller: pengirimAsalController,
                label: 'Asal Pengirim',
              ),
              _buildTextField(
                controller: pengirimDivisiController,
                label: 'Divisi Pengirim',
              ),
              _buildTextField(
                controller: pengirimDepartemenController,
                label: 'Departemen Pengirim',
              ),

              // ================= BAGIAN 2: DATA PENERIMA =================
              _buildSectionTitle('Data Penerima', Icons.people_outline),
              _buildTextField(
                controller: penerimaController,
                label: 'Tujuan Penerima',
              ),
              _buildTextField(
                controller: penerimaDivisiController,
                label: 'Divisi Penerima',
              ),
              _buildTextField(
                controller: penerimaDepartemenController,
                label: 'Departemen Penerima',
              ),

              // ================= BAGIAN 3: DATA SURAT =================
              _buildSectionTitle('Detail Surat', Icons.article_outlined),
              _buildTextField(
                controller: nomorController,
                label: 'Nomor Surat',
              ),
              _buildTextField(
                controller: perihalController,
                label: 'Perihal',
              ),
              _buildTextField(
                controller: deskripsiController,
                label: 'Deskripsi Surat',
                maxLines: 3,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedJenisSurat,
                  hint: Text('Pilih Jenis Surat', style: TextStyle(color: posBlue.withOpacity(0.8))),
                  icon: Icon(Icons.arrow_drop_down, color: posOrange),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: posBlue.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: posBlue.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: posOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: lightGrey,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  items: _jenisSuratOptions
                      .map((e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e, style: GoogleFonts.poppins())))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedJenisSurat = v),
                  validator: (v) => v == null ? 'Wajib dipilih' : null,
                  style: GoogleFonts.poppins(color: Colors.black87), // Style untuk teks yang dipilih
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedSifatSurat,
                  hint: Text('Pilih Sifat Surat', style: TextStyle(color: posBlue.withOpacity(0.8))),
                  icon: Icon(Icons.arrow_drop_down, color: posOrange),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: posBlue.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: posBlue.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: posOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: lightGrey,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  items: _sifatSuratOptions
                      .map((e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e, style: GoogleFonts.poppins())))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSifatSurat = v),
                  validator: (v) => v == null ? 'Wajib dipilih' : null,
                  style: GoogleFonts.poppins(color: Colors.black87), // Style untuk teks yang dipilih
                ),
              ),
              _buildTextField(
                controller: beratController,
                label: 'Berat Surat (gram)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              // ================= BAGIAN 4: UPLOAD FILE =================
              _buildSectionTitle('Lampiran Dokumen', Icons.attach_file),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickFileSurat,
                    icon: Icon(Icons.file_upload, color: posOrange),
                    label: Text('Lampirkan File Surat (Wajib)', style: GoogleFonts.poppins(color: posBlue)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: posBlue.withOpacity(0.7), width: 1.5),
                    ),
                  ),
                  if (_fileSurat != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'File Surat: ${_fileSurat!.path.split('/').last}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickFileLP,
                    icon: Icon(Icons.description_outlined, color: posOrange),
                    label: Text('Lampirkan File LP (Wajib)', style: GoogleFonts.poppins(color: posBlue)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: posBlue.withOpacity(0.7), width: 1.5),
                    ),
                  ),
                  if (_fileLP != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'File LP: ${_fileLP!.path.split('/').last}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                ],
              ),

              // Tombol Simpan
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label:
                    Text(widget.isEdit ? 'Simpan Perubahan' : 'Simpan Surat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: posOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  elevation: 5, // Memberi efek shadow
                ),
              ),
              const SizedBox(height: 20), // Memberi sedikit ruang di bawah
            ],
          ),
        ),
      ),
    );
  }
}