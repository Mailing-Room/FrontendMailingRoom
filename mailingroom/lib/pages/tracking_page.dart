// Path: lib/pages/tracking_page.dart
import 'package:flutter/material.dart';

// Model Surat
class Surat {
  final String id;
  final String nomor;
  final String perihal;
  final String deskripsiSurat;
  final String sifatSurat;
  final String? fileSuratUrl;
  final String? lpSuratUrl;
  final double berat;
  final String pengirimAsal;
  final String pengirimDivisi;
  final String pengirimDepartemen;
  final String penerimaTujuan;
  final String penerimaDivisi;
  final String penerimaDepartemen;
  final String jenisSurat;
  final String status;
  final String tanggal;

  Surat({
    required this.id,
    required this.nomor,
    required this.perihal,
    required this.deskripsiSurat,
    required this.sifatSurat,
    this.fileSuratUrl,
    this.lpSuratUrl,
    required this.berat,
    required this.pengirimAsal,
    required this.pengirimDivisi,
    required this.pengirimDepartemen,
    required this.penerimaTujuan,
    required this.penerimaDivisi,
    required this.penerimaDepartemen,
    required this.jenisSurat,
    required this.status,
    required this.tanggal,
  });
}

// Timeline Item Model
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

  // Data surat dummy
  final List<Surat> _dummySuratList = [
    Surat(
      id: '1',
      nomor: '123/PKS/X/2025',
      perihal: 'Perjanjian Kerja Sama Proyek A',
      deskripsiSurat: 'Dokumen perjanjian kerja sama proyek',
      sifatSurat: 'Penting',
      fileSuratUrl: null,
      lpSuratUrl: null,
      berat: 100.0,
      pengirimAsal: 'PT Sentosa Abadi',
      pengirimDivisi: 'Marketing',
      pengirimDepartemen: 'Sales',
      penerimaTujuan: 'penerima@mailingroom.com',
      penerimaDivisi: 'Keuangan',
      penerimaDepartemen: 'Accounting',
      jenisSurat: 'Masuk',
      status: 'Menunggu Kurir',
      tanggal: '2025-10-08',
    ),
    Surat(
      id: '2',
      nomor: '321/ED/X/2025',
      perihal: 'Surat Edaran Libur Nasional',
      deskripsiSurat: 'Surat edaran resmi mengenai libur nasional',
      sifatSurat: 'Biasa',
      fileSuratUrl: null,
      lpSuratUrl: null,
      berat: 50.0,
      pengirimAsal: 'Divisi HRD',
      pengirimDivisi: 'HR',
      pengirimDepartemen: 'General Affairs',
      penerimaTujuan: 'penerima@mailingroom.com',
      penerimaDivisi: 'Semua',
      penerimaDepartemen: 'Semua',
      jenisSurat: 'Keluar',
      status: 'Terkirim',
      tanggal: '2025-10-07',
    ),
  ];

  // Generate timeline berdasarkan status surat
  List<TimelineItem> _generateTimeline(Surat surat) {
    List<TimelineItem> timeline = [];

    // Timeline untuk surat masuk
    if (surat.jenisSurat == 'Masuk') {
      timeline.add(TimelineItem(
        status: 'Surat Dibuat',
        tanggal: '${surat.tanggal}, 08:00',
        lokasi: surat.pengirimAsal,
        petugas: surat.pengirimDivisi,
        catatan: 'Surat dibuat oleh ${surat.pengirimDepartemen}',
        isCompleted: true,
      ));

      timeline.add(TimelineItem(
        status: 'Diverifikasi',
        tanggal: '${surat.tanggal}, 09:30',
        lokasi: 'Mail Room',
        petugas: 'Admin Mail Room',
        catatan: 'Surat telah diverifikasi dan dicatat',
        isCompleted: true,
      ));

      if (surat.status == 'Menunggu Kurir') {
        timeline.add(TimelineItem(
          status: 'Menunggu Kurir',
          tanggal: '${surat.tanggal}, 10:00',
          lokasi: 'Mail Room',
          petugas: 'Waiting Assignment',
          catatan: 'Surat menunggu pengambilan oleh kurir',
          isCompleted: false,
        ));

        timeline.add(TimelineItem(
          status: 'Dalam Perjalanan',
          tanggal: '-',
          lokasi: '-',
          petugas: '-',
          catatan: 'Belum diproses',
          isCompleted: false,
        ));

        timeline.add(TimelineItem(
          status: 'Diterima',
          tanggal: '-',
          lokasi: surat.penerimaDivisi,
          petugas: '-',
          catatan: 'Belum diterima',
          isCompleted: false,
        ));
      }
    }

    // Timeline untuk surat keluar
    if (surat.jenisSurat == 'Keluar') {
      timeline.add(TimelineItem(
        status: 'Surat Dibuat',
        tanggal: '${surat.tanggal}, 08:00',
        lokasi: surat.pengirimDivisi,
        petugas: surat.pengirimDepartemen,
        catatan: 'Surat dibuat dan diajukan',
        isCompleted: true,
      ));

      timeline.add(TimelineItem(
        status: 'Diverifikasi',
        tanggal: '${surat.tanggal}, 09:15',
        lokasi: 'Sekretariat',
        petugas: 'Admin Sekretariat',
        catatan: 'Surat telah diverifikasi',
        isCompleted: true,
      ));

      timeline.add(TimelineItem(
        status: 'Dikirim',
        tanggal: '${surat.tanggal}, 10:30',
        lokasi: 'Mail Room',
        petugas: 'Kurir Internal',
        catatan: 'Surat dalam pengiriman',
        isCompleted: true,
      ));

      if (surat.status == 'Terkirim') {
        timeline.add(TimelineItem(
          status: 'Terkirim',
          tanggal: '${surat.tanggal}, 14:00',
          lokasi: surat.penerimaDivisi,
          petugas: 'Penerima',
          catatan: 'Surat telah diterima tujuan',
          isCompleted: true,
        ));
      }
    }

    return timeline;
  }

  void _searchSurat() {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nomor surat terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showResult = false;
    });

    // Simulasi loading - cari surat berdasarkan nomor
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final searchQuery = _searchController.text.trim();
        final foundSurat = _dummySuratList.firstWhere(
          (surat) => surat.nomor.toLowerCase() == searchQuery.toLowerCase(),
          orElse: () => _dummySuratList.first, // Default ke surat pertama jika tidak ditemukan
        );

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
      case 'terkirim':
      case 'diterima':
        return Colors.green;
      case 'menunggu kurir':
      case 'dalam perjalanan':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getSifatColor(String sifat) {
    switch (sifat.toLowerCase()) {
      case 'penting':
      case 'sangat penting':
        return Colors.red;
      case 'segera':
        return Colors.orange;
      case 'biasa':
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Lacak Surat'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Nomor Surat',
                      hintText: 'Contoh: 123/PKS/X/2025',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.article_outlined),
                      suffixIcon: IconButton(
                        icon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        onPressed: _isSearching ? null : _searchSurat,
                      ),
                    ),
                    onSubmitted: (_) => _searchSurat(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Contoh nomor surat: 123/PKS/X/2025 atau 321/ED/X/2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _searchSurat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Lacak Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Empty State
            if (!_showResult && !_isSearching)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hasil pelacakan akan muncul di sini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan nomor surat untuk melacak status pengiriman',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Result Section
            if (_showResult && _foundSurat != null) ...[
              const SizedBox(height: 8),

              // Detail Surat Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _foundSurat!.jenisSurat == 'Masuk'
                                ? Icons.call_received
                                : Icons.call_made,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _foundSurat!.nomor,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_foundSurat!.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _foundSurat!.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSifatColor(_foundSurat!.sifatSurat),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _foundSurat!.sifatSurat,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.subject,
                      label: 'Perihal',
                      value: _foundSurat!.perihal,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.description_outlined,
                      label: 'Deskripsi',
                      value: _foundSurat!.deskripsiSurat,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.business,
                      label: 'Pengirim',
                      value: '${_foundSurat!.pengirimAsal} - ${_foundSurat!.pengirimDivisi}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.place,
                      label: 'Tujuan',
                      value: '${_foundSurat!.penerimaDivisi} - ${_foundSurat!.penerimaDepartemen}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: _foundSurat!.tanggal,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.scale,
                      label: 'Berat',
                      value: '${_foundSurat!.berat} gram',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.category,
                      label: 'Jenis Surat',
                      value: _foundSurat!.jenisSurat,
                    ),
                  ],
                ),
              ),

              // Timeline Section
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Perjalanan Surat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._buildTimeline(_foundSurat!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTimeline(Surat surat) {
    List<Widget> timelineWidgets = [];
    List<TimelineItem> timeline = _generateTimeline(surat);

    for (int i = 0; i < timeline.length; i++) {
      timelineWidgets.add(
        _buildTimelineItem(
          item: timeline[i],
          isLast: i == timeline.length - 1,
        ),
      );
    }

    return timelineWidgets;
  }

  Widget _buildTimelineItem({
    required TimelineItem item,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.isCompleted ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted ? Colors.green : Colors.grey[400]!,
                  width: 3,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: item.isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: item.isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tanggal,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.isCompleted ? Colors.grey[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.lokasi,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: item.isCompleted ? Colors.black87 : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.petugas,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.catatan,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}