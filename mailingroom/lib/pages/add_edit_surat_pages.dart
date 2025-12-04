import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/surat.dart';

class AddEditSuratPage extends StatefulWidget {
  final Surat? surat;
  final bool isEdit;

  const AddEditSuratPage({super.key, this.surat, this.isEdit = false});

  @override
  State<AddEditSuratPage> createState() => _AddEditSuratPageState();
}

class _AddEditSuratPageState extends State<AddEditSuratPage> {
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);
  final Color inputFillColor = const Color(0xFFF8F9FA); // Warna input lebih terang

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller
  late TextEditingController nomorController;
  late TextEditingController perihalController;
  late TextEditingController deskripsiController;
  late TextEditingController penerimaController;
  late TextEditingController pengirimAsalController;

  // Dropdown Data
  String? _selectedJenisSurat;
  String? _selectedSifatSurat;
  final List<String> _jenisSuratOptions = ['Internal', 'Eksternal', 'Rahasia'];
  final List<String> _sifatSuratOptions = ['Biasa', 'Penting', 'Segera'];

  @override
  void initState() {
    super.initState();
    nomorController = TextEditingController(text: widget.surat?.nomor ?? '');
    perihalController = TextEditingController(text: widget.surat?.perihal ?? '');
    deskripsiController = TextEditingController(text: widget.surat?.deskripsiSurat ?? '');
    penerimaController = TextEditingController(text: widget.surat?.penerimaTujuan ?? '');
    pengirimAsalController = TextEditingController(text: widget.surat?.pengirimAsal ?? '');

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
    super.dispose();
  }

  void _saveForm() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate() || _selectedJenisSurat == null || _selectedSifatSurat == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua data wajib!'),
            backgroundColor: Colors.red,
          )
        );
        return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulasi Save
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Panggil Provider/Service untuk simpan ke database
      // final newSurat = Surat(...);
      // Provider.of<SuratProvider>(context, listen: false).addSurat(newSurat);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdit ? 'Data surat berhasil diperbarui!' : 'Surat berhasil dibuat!'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Background sedikit abu-abu
      
      // --- APP BAR SEDERHANA ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Edit Surat' : 'Registrasi Surat Baru',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
        ),
      ),

      // --- TOMBOL SIMPAN MELAYANG ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5)
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: posOrange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: posOrange.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            shadowColor: posOrange.withOpacity(0.4),
          ),
          child: _isLoading 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(
                widget.isEdit ? 'Simpan Perubahan' : 'Simpan Data Surat',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)
              ),
        ),
      ),

      // --- KONTEN FORM ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Kartu 1: Informasi Utama
              _buildFormSection(
                title: "Detail Surat",
                icon: Icons.article_outlined,
                children: [
                  _buildTextField(
                    controller: nomorController, 
                    label: "Nomor Surat", 
                    hint: "Contoh: 123/PKS/X/2025",
                    icon: Icons.tag_rounded
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: perihalController, 
                    label: "Perihal", 
                    hint: "Contoh: Undangan Rapat",
                    icon: Icons.title_rounded
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: deskripsiController, 
                    label: "Deskripsi Singkat", 
                    hint: "Tambahkan catatan atau ringkasan isi surat...",
                    icon: Icons.notes_rounded, 
                    maxLines: 3
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Kartu 2: Kategori
              _buildFormSection(
                title: "Klasifikasi",
                icon: Icons.category_outlined,
                children: [
                  _buildDropdown(
                    label: "Jenis Surat",
                    value: _selectedJenisSurat,
                    items: _jenisSuratOptions,
                    icon: Icons.folder_open_rounded,
                    onChanged: (val) => setState(() => _selectedJenisSurat = val),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(
                    label: "Sifat Surat",
                    value: _selectedSifatSurat,
                    items: _sifatSuratOptions,
                    icon: Icons.priority_high_rounded,
                    onChanged: (val) => setState(() => _selectedSifatSurat = val),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Kartu 3: Distribusi
              _buildFormSection(
                title: "Alur Distribusi",
                icon: Icons.send_outlined,
                children: [
                  _buildTextField(
                    controller: pengirimAsalController, 
                    label: "Pengirim", 
                    hint: "Nama atau Divisi Pengirim",
                    icon: Icons.outbox_rounded
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: penerimaController, 
                    label: "Penerima", 
                    hint: "Nama atau Divisi Penerima",
                    icon: Icons.inbox_rounded
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER (CLEAN DESIGN) ---

  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: posBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: posBlue, size: 22),
              ),
              const SizedBox(width: 16),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required String hint, 
    required IconData icon, 
    int maxLines = 1
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: inputFillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: posBlue, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label, 
    required String? value, 
    required List<String> items, 
    required IconData icon, 
    required Function(String?) onChanged
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: (v) => v == null ? 'Pilih salah satu' : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500]),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: inputFillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
          ),
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 15))
          )).toList(),
        ),
      ],
    );
  }
}