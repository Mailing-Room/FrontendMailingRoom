// lib/pages/dashboard/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/auth/auth_service.dart'; // ✅ Import AuthService

// Import yang diperlukan untuk data surat
import '../../models/surat.dart';
import '../../providers/surat_provider.dart';

// Enum untuk mengelola halaman yang aktif
enum AdminPage { dashboard, kelolaSurat, kelolaUser, kelolaDivisi, cetakLaporan }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminPage _selectedPage = AdminPage.dashboard;
  bool _isSidebarExpanded = false;

  final TextEditingController _suratSearchController = TextEditingController();
  String _suratSearchQuery = '';

  // Warna tema PT Pos Indonesia
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);
  final Color posRed = const Color(0xFFC62828); // Hanya untuk aksi Hapus
  final Color lightBg = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _suratSearchController.addListener(() {
      setState(() {
        _suratSearchQuery = _suratSearchController.text;
      });
    });
  }

  @override
  void dispose() {
    _suratSearchController.dispose();
    super.dispose();
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarExpanded = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 850;

        if (!isMobile) {
          _isSidebarExpanded = true;
        }

        // Tampilan untuk Desktop
        if (!isMobile) {
          return Scaffold(
            backgroundColor: lightBg,
            body: Row(
              children: [
                _buildSideBar(context, isMobile: false), // Kirim context
                Expanded(child: _buildMainContent(isMobile: false)),
              ],
            ),
          );
        }

        // Tampilan untuk Mobile
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Tutup keyboard
          child: Scaffold(
            backgroundColor: lightBg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87, // Warna ikon & font hitam
              elevation: 1.0,
              title: Text(_getPageTitle(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  FocusScope.of(context).unfocus(); // Tutup keyboard sblm buka menu
                  setState(() {
                    _isSidebarExpanded = !_isSidebarExpanded;
                  });
                },
              ),
            ),
            body: Stack(
              children: [
                _buildMainContent(isMobile: true),
                if (_isSidebarExpanded) ...[
                  GestureDetector(
                    onTap: _closeSidebar,
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                  _buildSideBar(context, isMobile: true), // Kirim context
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPageTitle() {
    switch (_selectedPage) {
      case AdminPage.dashboard: return 'Dashboard';
      case AdminPage.kelolaSurat: return 'Kelola Surat';
      case AdminPage.kelolaUser: return 'Kelola User';
      case AdminPage.kelolaDivisi: return 'Kelola Divisi';
      case AdminPage.cetakLaporan: return 'Cetak Laporan';
    }
  }
  
  Widget _buildSideBar(BuildContext context, {required bool isMobile}) { // ✅ Terima context
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isSidebarExpanded ? 250 : (isMobile ? 0 : 70),
      color: posBlue, 
      child: Column(
        children: [
          // --- HEADER SIDEBAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/POSIND_2023.png', height: 32, errorBuilder: (c,e,s) => const Icon(Icons.mark_email_read, color: Colors.white, size: 32)),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pos Indonesia', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Mailing Room System', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1, indent: 16, endIndent: 16),
          
          // --- DAFTAR MENU (SCROLLABLE) ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSideBarItem(context: context, title: 'Dashboard', icon: Icons.dashboard_outlined, page: AdminPage.dashboard, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola Surat', icon: Icons.drafts_outlined, page: AdminPage.kelolaSurat, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola User', icon: Icons.people_outline, page: AdminPage.kelolaUser, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola Divisi', icon: Icons.business_outlined, page: AdminPage.kelolaDivisi, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Cetak Laporan', icon: Icons.print_outlined, page: AdminPage.cetakLaporan, isMobile: isMobile),
                ],
              ),
            ),
          ),

          // --- TOMBOL LOGOUT (MENEMPEL DI BAWAH) ---
          const Divider(color: Colors.white24, height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),
          _buildSideBarItem(context: context, title: 'Logout', icon: Icons.logout, page: null, isLogout: true, isMobile: isMobile),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSideBarItem({required BuildContext context, required String title, required IconData icon, required bool isMobile, AdminPage? page, bool isLogout = false}) { // ✅ Terima context
    final bool isSelected = _selectedPage == page;
    return InkWell(
      onTap: () {
        if (isLogout) {
          // ✅ PANGGIL FUNGSI SIGNOUT
          Provider.of<AuthService>(context, listen: false).signOut();
        } else if (page != null) {
          setState(() {
            _selectedPage = page;
            if (isMobile) _isSidebarExpanded = false;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? posOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (_isSidebarExpanded) ...[
              const SizedBox(width: 16),
              Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({required bool isMobile}) {
    // Dipisahkan agar `SingleChildScrollView` tidak ada di Kelola Surat
    switch (_selectedPage) {
      case AdminPage.dashboard:
        return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 16 : 32), child: _buildDashboardContent(isMobile: isMobile));
      case AdminPage.kelolaSurat:
        return _buildKelolaSuratContent(isMobile: isMobile); // Halaman ini punya scroll sendiri
      case AdminPage.kelolaUser:
        return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 16 : 32), child: _buildKelolaUserContent(isMobile: isMobile));
      case AdminPage.kelolaDivisi:
        return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 16 : 32), child: _buildKelolaDivisiContent(isMobile: isMobile));
      case AdminPage.cetakLaporan:
        return Center(child: Text('Halaman Cetak Laporan', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)));
    }
  }

  Widget _buildDashboardContent({required bool isMobile}) {
    final List<Map<String, dynamic>> stats = [
      {'title': 'Total Surat Keluar', 'value': '987', 'icon': Icons.mail_outline, 'color': Colors.green},
      {'title': 'Total User', 'value': '3', 'icon': Icons.people_alt_outlined, 'color': posBlue},
      {'title': 'Total Divisi', 'value': '3', 'icon': Icons.business_center_outlined, 'color': posOrange},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) Text('Dashboard', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
        if (!isMobile) const SizedBox(height: 24),
        Text('Ringkasan', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 3 : 2.2,
          ),
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(stat['title'] as String, stat['value'] as String, stat['icon'] as IconData, stat['color'] as Color);
          },
        ),
        const SizedBox(height: 32),
        Text('Aktivitas Terbaru', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildActivityItem('Surat masuk dari PT. ABC', '5 menit yang lalu', 'Baru', posOrange),
                const Divider(height: 24),
                _buildActivityItem('Surat keluar ke Divisi IT', '1 jam yang lalu', 'Terkirim', posBlue),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.poppins(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value, 
                      style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityItem(String title, String time, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(time, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildKelolaSuratContent({required bool isMobile}) {
    final provider = Provider.of<SuratProvider>(context, listen: false);
    final statusOptions = ['Menunggu Kurir', 'Dalam Proses', 'Selesai Diantar', 'Gagal'];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 0 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text('Kelola Surat', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                ),
              TextField(
                controller: _suratSearchController,
                decoration: InputDecoration(
                  labelText: 'Cari berdasarkan Perihal atau Pengirim',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _suratSearchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear), 
                        onPressed: () {
                          _suratSearchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ) 
                    : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: StreamBuilder<List<Surat>>(
                stream: provider.allSuratStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                  }
                  final suratList = snapshot.data ?? [];
                  
                  final filteredList = suratList.where((surat) {
                    final query = _suratSearchQuery.toLowerCase();
                    return surat.perihal.toLowerCase().contains(query) ||
                           surat.pengirimAsal.toLowerCase().contains(query);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(_suratSearchQuery.isEmpty ? 'Tidak ada surat untuk dikelola.' : 'Surat tidak ditemukan.')));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                      dataRowHeight: 60,
                      columns: const [
                        DataColumn(label: Text('PERIHAL')),
                        DataColumn(label: Text('PENGIRIM')),
                        DataColumn(label: Text('STATUS SAAT INI')),
                        DataColumn(label: Text('AKSI (UBAH STATUS)')),
                      ],
                      rows: filteredList.map((surat) => DataRow(cells: [
                        DataCell(Text(surat.perihal, style: GoogleFonts.poppins())),
                        DataCell(Text(surat.pengirimAsal, style: GoogleFonts.poppins())),
                        DataCell(_buildStatusChip(surat.status)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton<String>(
                              value: statusOptions.contains(surat.status) ? surat.status : null,
                              hint: const Text('Pilih Aksi'),
                              underline: Container(),
                              onChanged: (newStatus) {
                                if (newStatus != null && surat.id != null) {
                                  provider.updateSuratStatus(surat.id!, newStatus);
                                }
                              },
                              items: statusOptions.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status, style: GoogleFonts.poppins(fontSize: 14)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ])).toList(),
                    )
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }


  Widget _buildKelolaUserContent({required bool isMobile}) {
    final users = [
      {'nama': 'Budi Santoso', 'email': 'budi@posindo.co.id', 'role': 'Staff', 'divisi': 'IT'},
      {'nama': 'Siti Nurhaliza', 'email': 'siti@posindo.co.id', 'role': 'Manager', 'divisi': 'Finance'},
      {'nama': 'Ahmad Rizki', 'email': 'ahmad@posindo.co.id', 'role': 'Staff', 'divisi': 'Operations'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isMobile) Text('Kelola User', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah User'),
              style: ElevatedButton.styleFrom(backgroundColor: posOrange),
            )
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                  dataRowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                  dataRowHeight: 60,
                  columns: const [
                    DataColumn(label: Text('NAMA')),
                    DataColumn(label: Text('EMAIL')),
                    DataColumn(label: Text('ROLE')),
                    DataColumn(label: Text('DIVISI')),
                    DataColumn(label: Text('AKSI')),
                  ],
                  rows: users.map((user) => DataRow(cells: [
                    DataCell(Text(user['nama']!)),
                    DataCell(Text(user['email']!)),
                    DataCell(_buildRoleChip(user['role']!)),
                    DataCell(Text(user['divisi']!)),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), color: posBlue, tooltip: 'Edit', onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline), color: posRed, tooltip: 'Hapus', onPressed: () {}),
                    ])),
                  ])).toList(),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    Color color = role == 'Staff' ? posBlue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(role, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    if (status.contains('Menunggu')) { color = posOrange; }
    else if (status.contains('Proses')) { color = posBlue; }
    else if (status.contains('Selesai') || status.contains('Terkirim')) { color = Colors.green; }
    else { color = posRed; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildKelolaDivisiContent({required bool isMobile}) {
    final depts = [
      {'nama': 'IT', 'kode': 'IT-01', 'telepon': '021-1234567'},
      {'nama': 'Finance', 'kode': 'FIN-01', 'telepon': '021-1234568'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isMobile) Text('Kelola Divisi', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showTambahDivisiDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah Divisi'),
              style: ElevatedButton.styleFrom(backgroundColor: posOrange),
            )
          ],
        ),
        const SizedBox(height: 20),
         SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                   dataRowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                  dataRowHeight: 60,
                  columns: const [
                    DataColumn(label: Text('NAMA DIVISI')),
                    DataColumn(label: Text('KODE')),
                    DataColumn(label: Text('TELEPON')),
                    DataColumn(label: Text('AKSI')),
                  ],
                  rows: depts.map((dept) => DataRow(cells: [
                    DataCell(Text(dept['nama']!)),
                    DataCell(Text(dept['kode']!)),
                    DataCell(Text(dept['telepon']!)),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), color: posBlue, onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline), color: posRed, onPressed: () {}),
                    ])),
                  ])).toList(),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void _showTambahDivisiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tambah Divisi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: posBlue)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField('Nama Divisi'),
                  _buildDialogTextField('Kode'),
                  _buildDialogTextField('Alamat'),
                  _buildDialogTextField('Telepon'),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[700])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: posOrange),
              child: const Text('Simpan'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDialogTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}