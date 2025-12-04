import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Import Provider & Model
import '../models/surat.dart';
import '../providers/surat_provider.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  bool _hasSearched = false;
  Surat? _foundSurat;

  // Warna Tema
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi pencarian menerima List<Surat> dari StreamBuilder
  void _handleSearch(List<Surat> allSurat) {
    FocusScope.of(context).unfocus(); // Tutup keyboard
    
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor surat terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _searchQuery = _searchController.text.trim();
      _hasSearched = true;
      
      // LOGIKA PENCARIAN:
      // Mencari surat yang nomornya COCOK (Case Insensitive)
      try {
        _foundSurat = allSurat.firstWhere(
          (s) => s.nomor.toLowerCase() == _searchQuery.toLowerCase(),
        );
      } catch (e) {
        _foundSurat = null; // Tidak ketemu
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil provider (listen: false)
    final suratProvider = Provider.of<SuratProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Lacak Kiriman', 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      // --- PERBAIKAN: Gunakan StreamBuilder ---
      // Kita mendengarkan 'allSuratStream' langsung, tidak mengakses 'suratList'
      body: StreamBuilder<List<Surat>>(
        stream: suratProvider.allSuratStream,
        builder: (context, snapshot) {
          
          // Data sementara (kosong jika loading/error)
          final List<Surat> allSurat = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 1. SEARCH SECTION
                // Kita kirim 'allSurat' ke widget ini agar tombol cari bisa menggunakannya
                _buildSearchCard(allSurat),
                
                const SizedBox(height: 24),

                // 2. RESULT SECTION
                // Tampilkan loading jika data sedang diambil dari server
                if (snapshot.connectionState == ConnectionState.waiting && !_hasSearched)
                   const Padding(
                     padding: EdgeInsets.only(top: 50),
                     child: CircularProgressIndicator(),
                   )
                else if (_hasSearched)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _foundSurat != null 
                        ? _buildTrackingResult(_foundSurat!) 
                        : _buildNotFound(),
                  )
                else 
                  _buildIllustrationState(),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildSearchCard(List<Surat> allSurat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nomor Resi / Surat",
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Contoh: 123/PKS/X/2025',
              hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.qr_code_scanner_rounded, color: posBlue),
            ),
            // Panggil _handleSearch saat Enter ditekan
            onSubmitted: (_) => _handleSearch(allSurat),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Panggil _handleSearch saat Tombol ditekan
              onPressed: () => _handleSearch(allSurat),
              style: ElevatedButton.styleFrom(
                backgroundColor: posOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: Text(
                'Lacak Sekarang', 
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingResult(Surat surat) {
    return FadeInUp(
      child: Column(
        children: [
          // KARTU INFORMASI UTAMA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [posBlue, const Color(0xFF0073E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: posBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Status Terkini", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(surat.jenisSurat.toUpperCase(), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  surat.status,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Diperbarui: ${_formatTanggal(surat.tanggal)}",
                  style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pengirim", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                          Text(surat.pengirimAsal, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 16),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Penerima", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                          Text(surat.penerimaTujuan ?? "-", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 32),

          // TIMELINE SECTION
          _buildTimelineList(surat),
        ],
      ),
    );
  }

  Widget _buildTimelineList(Surat surat) {
    // Logika Cerdas Timeline berdasarkan Status
    int currentStep = 1;
    final s = surat.status.toLowerCase();
    
    if (s.contains('menunggu')) currentStep = 1;
    else if (s.contains('proses') || s.contains('kurir')) currentStep = 2;
    else if (s.contains('jalan') || s.contains('kirim')) currentStep = 3;
    else if (s.contains('selesai') || s.contains('terima') || s.contains('terkirim')) currentStep = 4;

    final steps = [
      {'title': 'Surat Dibuat', 'desc': 'Surat telah didaftarkan ke sistem', 'isCompleted': currentStep >= 1},
      {'title': 'Dijemput Kurir', 'desc': 'Kurir sedang menuju lokasi pengirim', 'isCompleted': currentStep >= 2},
      {'title': 'Dalam Perjalanan', 'desc': 'Surat sedang diantar ke tujuan', 'isCompleted': currentStep >= 3},
      {'title': 'Selesai', 'desc': 'Surat telah diterima oleh ${surat.penerimaTujuan}', 'isCompleted': currentStep >= 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16),
          child: Text("Riwayat Perjalanan", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isCompleted = step['isCompleted'] as bool;
              final isLast = index == steps.length - 1;

              return TimelineTile(
                isFirst: index == 0,
                isLast: isLast,
                beforeLineStyle: LineStyle(
                  color: isCompleted ? posOrange : Colors.grey[300]!,
                  thickness: 2,
                ),
                indicatorStyle: IndicatorStyle(
                  width: 30,
                  color: isCompleted ? posOrange : Colors.grey[300]!,
                  iconStyle: IconStyle(
                    iconData: isCompleted ? Icons.check : Icons.circle,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.black87 : Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['desc'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Surat Tidak Ditemukan",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Pastikan nomor surat yang Anda masukkan benar.\nCoba cek kembali ejaan dan formatnya.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustrationState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.local_shipping_outlined, size: 100, color: Colors.grey[200]),
            const SizedBox(height: 24),
            Text(
              "Lacak posisi surat Anda",
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTanggal(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal);
      return DateFormat('d MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return "-";
    }
  }
}