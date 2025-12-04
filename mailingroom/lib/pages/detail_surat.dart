import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/surat.dart';

class DetailSuratPage extends StatelessWidget {
  final Surat surat;
  const DetailSuratPage({super.key, required this.surat});

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    final Color posBlue = const Color(0xFF00529C);
    final Color posOrange = const Color(0xFFF37021);
    final Color bgColor = const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND (Gradient)
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [posBlue, const Color(0xFF0073E6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. APP BAR TRANSPARAN
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Detail Surat",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer penyeimbang tombol back
                ],
              ),
            ),
          ),

          // 3. KONTEN UTAMA (Scrollable Card)
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // --- KARTU STATUS UTAMA ---
                  _buildStatusBanner(surat),
                  
                  const SizedBox(height: 20),

                  // --- KARTU DETAIL SURAT ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Kartu (Nomor & Tanggal)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Nomor Surat"),
                              const SizedBox(height: 4),
                              Text(
                                surat.nomor,
                                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel("Tanggal"),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[500]),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(surat.tanggal),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Isi Detail
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Perihal"),
                              const SizedBox(height: 8),
                              Text(
                                surat.perihal,
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.5),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              Row(
                                children: [
                                  Expanded(child: _buildMiniInfo("Jenis", surat.jenisSurat, Icons.folder_open_rounded, Colors.blue)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildMiniInfo("Sifat", surat.sifatSurat, Icons.flag_outlined, posOrange)),
                                ],
                              ),

                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),

                              _buildLabel("Deskripsi / Catatan"),
                              const SizedBox(height: 8),
                              Text(
                                (surat.deskripsiSurat ?? "").isNotEmpty ? surat.deskripsiSurat! : "-",
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[600], height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- KARTU ALUR DISTRIBUSI (Visual Timeline) ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alur Distribusi", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 24),
                        
                        // Pengirim
                        _buildDistributionStep(
                          icon: Icons.outbox_rounded,
                          iconColor: Colors.blue,
                          title: "Pengirim",
                          value: surat.pengirimAsal,
                          isLast: false,
                        ),
                        
                        // Penerima
                        _buildDistributionStep(
                          icon: Icons.inbox_rounded,
                          iconColor: Colors.green,
                          title: "Penerima",
                          value: surat.penerimaTujuan ?? "-",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                   // --- KARTU LAMPIRAN ---
                  if (surat.fileSuratUrl != null) // Tampilkan hanya jika ada file
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lampiran Dokumen", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 16),
                          _buildFileItem("File Surat Utama", Icons.description_outlined, surat.fileSuratUrl),
                          // Bagian fileLpUrl dihapus karena tidak ada di model
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatusBanner(Surat surat) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text = surat.status;

    if (text.toLowerCase().contains('terkirim') || text.toLowerCase().contains('selesai')) {
      bgColor = Colors.green;
      textColor = Colors.white;
      icon = Icons.check_circle_rounded;
    } else if (text.toLowerCase().contains('menunggu') || text.toLowerCase().contains('pending')) {
      bgColor = const Color(0xFFF37021); // Orange
      textColor = Colors.white;
      icon = Icons.hourglass_top_rounded;
    } else {
      bgColor = const Color(0xFF00529C); // Blue
      textColor = Colors.white;
      icon = Icons.sync_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: bgColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status Terkini", style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
              Text(text, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey[400],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDistributionStep({required IconData icon, required Color iconColor, required String title, required String value, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(String label, IconData icon, String? url) {
    bool hasFile = url != null && url.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: hasFile ? const Color(0xFFF37021) : Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label, 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: hasFile ? Colors.black87 : Colors.grey[400])
            ),
          ),
          if (hasFile)
            Icon(Icons.download_rounded, color: Colors.grey[600], size: 20)
          else
            Text("Tidak ada", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}