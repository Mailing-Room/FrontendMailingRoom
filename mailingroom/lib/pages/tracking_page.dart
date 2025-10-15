// lib/pages/tracking_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:animate_do/animate_do.dart';

// Import halaman dan model yang diperlukan
import 'qr_scanner_page.dart';
import '../models/surat.dart'; //  Menggunakan model Surat terpusat

//  Definisi class Surat yang duplikat sudah dihapus dari sini

class TimelineItem {
  final String status;
  final String tanggal;
  final String lokasi;
  final String petugas;
  final String catatan;
  final bool isCompleted;

  TimelineItem({
    required this.status,
    required this.tanggal,
    required this.lokasi,
    required this.petugas,
    required this.catatan,
    required this.isCompleted,
  });
}

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showResult = false;
  Surat? _foundSurat;

  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);

  // DATA DUMMY
  final List<Surat> _dummySuratList = [
    Surat(id: '1', nomor: '123/PKS/X/2025', perihal: 'Perjanjian Kerja Sama Proyek A', deskripsiSurat: 'Dokumen perjanjian kerja sama proyek', sifatSurat: 'Penting', berat: 100.0, pengirimAsal: 'PT Sentosa Abadi', pengirimDivisi: 'Marketing', pengirimDepartemen: 'Sales', penerimaTujuan: 'penerima@mailingroom.com', penerimaDivisi: 'Keuangan', penerimaDepartemen: 'Accounting', jenisSurat: 'Masuk', status: 'Dalam Perjalanan', tanggal: '2025-10-13'),
    Surat(id: '2', nomor: '321/ED/X/2025', perihal: 'Surat Edaran Libur Nasional', deskripsiSurat: 'Surat edaran resmi mengenai libur nasional', sifatSurat: 'Biasa', berat: 50.0, pengirimAsal: 'Divisi HRD', pengirimDivisi: 'HR', pengirimDepartemen: 'General Affairs', penerimaTujuan: 'penerima@mailingroom.com', penerimaDivisi: 'Semua', penerimaDepartemen: 'Semua', jenisSurat: 'Keluar', status: 'Terkirim', tanggal: '2025-10-14'),
  ];

  // FUNGSI UNTUK MEMBUKA SCANNER
  Future<void> _scanQRCode() async {
    try {
      final scannedData = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );
      if (scannedData != null && scannedData.isNotEmpty) {
        setState(() {
          _searchController.text = scannedData;
        });
        _searchSurat();
      }
    } catch (e) {
      print('Error saat membuka scanner: $e');
    }
  }

  List<TimelineItem> _generateTimeline(Surat surat) {
    List<TimelineItem> timeline = [];
    if (surat.jenisSurat == 'Masuk') {
      timeline.add(TimelineItem(status: 'Surat Dibuat', tanggal: '${surat.tanggal}, 08:00', lokasi: surat.pengirimAsal, petugas: surat.pengirimDivisi, catatan: 'Surat dibuat oleh ${surat.pengirimDepartemen}', isCompleted: true));
      timeline.add(TimelineItem(status: 'Diverifikasi', tanggal: '${surat.tanggal}, 09:30', lokasi: 'Mail Room', petugas: 'Admin Mail Room', catatan: 'Surat telah diverifikasi', isCompleted: true));
      bool inTransit = surat.status == 'Dalam Perjalanan';
      timeline.add(TimelineItem(status: 'Dalam Perjalanan', tanggal: inTransit ? '${surat.tanggal}, 11:00' : '-', lokasi: inTransit ? 'Sortir Jakarta Utara' : '-', petugas: inTransit ? 'Kurir Express' : '-', catatan: inTransit ? 'Menuju lokasi penerima' : 'Belum diproses', isCompleted: inTransit));
      timeline.add(TimelineItem(status: 'Diterima', tanggal: '-', lokasi: surat.penerimaDivisi ?? '-', petugas: '-', catatan: 'Belum diterima', isCompleted: false));
    }
     if (surat.jenisSurat == 'Keluar') {
      timeline.add(TimelineItem(status: 'Surat Dibuat', tanggal: '${surat.tanggal}, 08:00', lokasi: surat.pengirimDivisi, petugas: surat.pengirimDepartemen, catatan: 'Surat dibuat dan diajukan', isCompleted: true));
      timeline.add(TimelineItem(status: 'Diverifikasi', tanggal: '${surat.tanggal}, 09:15', lokasi: 'Sekretariat', petugas: 'Admin Sekretariat', catatan: 'Surat telah diverifikasi', isCompleted: true));
      timeline.add(TimelineItem(status: 'Dikirim', tanggal: '${surat.tanggal}, 10:30', lokasi: 'Mail Room', petugas: 'Kurir Internal', catatan: 'Surat dalam pengiriman', isCompleted: true));
      if (surat.status == 'Terkirim') {
        timeline.add(TimelineItem(status: 'Terkirim', tanggal: '${surat.tanggal}, 14:00', lokasi: surat.penerimaDivisi ?? '-', petugas: 'Penerima', catatan: 'Surat telah diterima tujuan', isCompleted: true));
      }
    }
    return timeline;
  }
  
  void _searchSurat() {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Masukkan nomor surat terlebih dahulu'), backgroundColor: Colors.red[600]));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _isSearching = true; _showResult = false; });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final searchQuery = _searchController.text.trim();
        Surat? foundSurat;
        try {
          foundSurat = _dummySuratList.firstWhere((s) => s.nomor.toLowerCase() == searchQuery.toLowerCase());
        } catch (e) {
          foundSurat = null;
        }
        setState(() {
          _foundSurat = foundSurat;
          _isSearching = false;
          _showResult = true;
        });
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terkirim': case 'diterima': return Colors.green.shade600;
      case 'menunggu kurir': case 'dalam perjalanan': return Colors.orange.shade600;
      case 'pending': return Colors.grey.shade600;
      default: return posBlue;
    }
  }

  Color _getSifatColor(String sifat) {
    switch (sifat.toLowerCase()) {
      case 'penting': return Colors.red.shade600;
      case 'segera': return posOrange;
      default: return Colors.blue.shade600;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isSearching) return _buildLoadingIndicator();
    if (_showResult) {
      return _foundSurat != null ? _buildResultContent() : _buildNotFoundContent();
    }
    return _buildEmptyState();
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: posBlue,
      foregroundColor: Colors.white,
      pinned: true,
      expandedHeight: 260.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text('Lacak Kiriman Surat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [posBlue, posBlue.withOpacity(0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 50, left: 20,
                child: Row(
                  children: [
                    Image.asset('assets/images/logo_pos_white.png', height: 25, errorBuilder: (c,e,s) => const SizedBox()),
                    const SizedBox(width: 10),
                    Text("POS IND", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24))
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 110.0), child: _buildSearchCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Masukkan Nomor Surat...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon: IconButton(
                icon: Icon(Icons.qr_code_scanner, color: posBlue),
                onPressed: _scanQRCode,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            onSubmitted: (_) => _searchSurat(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchSurat,
                icon: const Icon(Icons.search, size: 20),
                label: Text('Lacak Kiriman', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: posOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
   Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset('assets/images/kurir.png', height: 180, errorBuilder: (context, error, stackTrace) => Icon(Icons.local_shipping_outlined, size: 120, color: Colors.grey[300])), 
          const SizedBox(height: 24),
          Text(
            'Selamat Datang di Lacak Kiriman',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: posBlue),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan nomor surat pada kolom di atas untuk melihat status dan riwayat perjalanan kiriman Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: posOrange),
            const SizedBox(height: 16),
            Text('Mencari surat...', style: GoogleFonts.poppins(fontSize: 16, color: posBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundContent() {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.search_off_rounded, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Kiriman Tidak Ditemukan',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: posBlue),
            ),
            const SizedBox(height: 8),
            Text(
              'Nomor surat yang Anda masukkan tidak terdaftar. Mohon periksa kembali.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    final List<TimelineItem> timeline = _generateTimeline(_foundSurat!);
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSuratDetailCard(),
            const SizedBox(height: 16),
            _buildTimelineCard(timeline),
          ],
        ),
      ),
    );
  }

  Widget _buildSuratDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: posBlue,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.article, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nomor Surat", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                      Text(
                        _foundSurat!.nomor,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_foundSurat!.perihal, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(_foundSurat!.status, _getStatusColor(_foundSurat!.status)),
                    _buildInfoChip(_foundSurat!.sifatSurat, _getSifatColor(_foundSurat!.sifatSurat)),
                    _buildInfoChip('${_foundSurat!.berat} gr', Colors.grey.shade600),
                  ],
                ),
                const Divider(height: 24),
                _buildDetailRow('Pengirim', '${_foundSurat!.pengirimAsal} - ${_foundSurat!.pengirimDivisi}'),
                const SizedBox(height: 12),
                _buildDetailRow('Penerima', '${_foundSurat!.penerimaDivisi} - ${_foundSurat!.penerimaDepartemen}'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildTimelineCard(List<TimelineItem> timeline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Perjalanan',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: posBlue),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              final bool isCurrent = item.isCompleted && (index + 1 == timeline.length || !timeline[index + 1].isCompleted);
              
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isFirst: index == 0,
                isLast: index == timeline.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 35,
                  height: 35,
                  indicator: Pulse(
                    animate: isCurrent,
                    duration: const Duration(seconds: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.isCompleted ? posOrange : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCurrent ? Icons.local_shipping : (item.isCompleted ? Icons.check : Icons.more_horiz),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                beforeLineStyle: LineStyle(color: item.isCompleted ? posOrange : Colors.grey[300]!, thickness: 3),
                endChild: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 24, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.status, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: item.isCompleted ? posBlue : Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(item.tanggal, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Lokasi: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black54)),
                            TextSpan(text: item.lokasi),
                          ],
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800]),
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Petugas: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black54)),
                            TextSpan(text: item.petugas),
                          ],
                           style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800]),
                        ),
                      ),
                       Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Catatan: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black54)),
                            TextSpan(text: item.catatan, style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                           style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}