// lib/pages/dashboard/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/main.dart'; // Asumsi main.dart punya warna tema

// Enum untuk mengelola halaman yang aktif
enum AdminPage { dashboard, kelolaUser, kelolaDivisi, cetakLaporan }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminPage _selectedPage = AdminPage.dashboard;
  bool _isSidebarExpanded = false;

  // Warna tema PT Pos Indonesia
  final Color posOrange = const Color(0xFFF37021); // Menggunakan kode hex standar Pos
  final Color posBlue = const Color(0xFF00529C);
  final Color posRed = const Color(0xFFC62828); // Tetap dipakai untuk aksi 'Hapus'
  final Color lightBg = const Color(0xFFF5F7FA); // Latar belakang abu-abu muda

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
                _buildSideBar(isMobile: false),
                Expanded(child: _buildMainContent(isMobile: false)),
              ],
            ),
          );
        }

        // Tampilan untuk Mobile
        return Scaffold(
          backgroundColor: lightBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: posBlue, // ✅ Diubah ke Biru
            elevation: 1.0,
            title: Text(_getPageTitle(),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
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
                _buildSideBar(isMobile: true),
              ]
            ],
          ),
        );
      },
    );
  }

  String _getPageTitle() {
    switch (_selectedPage) {
      case AdminPage.dashboard:
        return 'Dashboard';
      case AdminPage.kelolaUser:
        return 'Kelola User';
      case AdminPage.kelolaDivisi:
        return 'Kelola Divisi';
      case AdminPage.cetakLaporan:
        return 'Cetak Laporan';
    }
  }

  Widget _buildSideBar({required bool isMobile}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isSidebarExpanded ? 250 : (isMobile ? 0 : 70),
      color: posBlue, // ✅ Diubah ke Biru
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    color: Colors.white, size: 32),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pos Indonesia',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text('Mailing Room System',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ],
            ),
          ),
          _buildSideBarItem(
              title: 'Dashboard',
              icon: Icons.dashboard_outlined,
              page: AdminPage.dashboard,
              isMobile: isMobile),
          _buildSideBarItem(
              title: 'Kelola User',
              icon: Icons.people_outline,
              page: AdminPage.kelolaUser,
              isMobile: isMobile),
          _buildSideBarItem(
              title: 'Kelola Divisi',
              icon: Icons.business_outlined,
              page: AdminPage.kelolaDivisi,
              isMobile: isMobile),
          _buildSideBarItem(
              title: 'Cetak Laporan',
              icon: Icons.print_outlined,
              page: AdminPage.cetakLaporan,
              isMobile: isMobile),
          const Spacer(),
          _buildSideBarItem(
              title: 'Logout',
              icon: Icons.logout,
              page: null,
              isLogout: true,
              isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildSideBarItem(
      {required String title,
      required IconData icon,
      required bool isMobile,
      AdminPage? page,
      bool isLogout = false}) {
    final bool isSelected = _selectedPage == page;
    return InkWell(
      onTap: () {
        if (isLogout) {
          print('Logout');
        } else if (page != null) {
          setState(() {
            _selectedPage = page;
            if (isMobile) _isSidebarExpanded = false;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? posOrange : Colors.transparent, // ✅ Diubah ke Oranye
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: _isSidebarExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (_isSidebarExpanded) ...[
              const SizedBox(width: 16),
              Text(title,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({required bool isMobile}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: switch (_selectedPage) {
        AdminPage.dashboard => _buildDashboardContent(isMobile: isMobile),
        AdminPage.kelolaUser => _buildKelolaUserContent(isMobile: isMobile),
        AdminPage.kelolaDivisi => _buildKelolaDivisiContent(isMobile: isMobile),
        AdminPage.cetakLaporan => Center(
            child: Text('Halaman Cetak Laporan',
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold))),
      },
    );
  }

  Widget _buildDashboardContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          Text('Dashboard',
              style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.bold)),
        if (!isMobile) const SizedBox(height: 24),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 2.5 : 2,
          ),
          itemCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final stats = [
              {
                'title': 'Total Surat Keluar',
                'value': '987',
                'icon': Icons.mail_outline,
                'color': Colors.green
              },
              {
                'title': 'Total User',
                'value': '3',
                'icon': Icons.people_alt_outlined,
                'color': posBlue // ✅ Diubah ke Biru
              },
              {
                'title': 'Total Divisi',
                'value': '3',
                'icon': Icons.business_center_outlined,
                'color': posOrange // ✅ Diubah ke Oranye
              },
            ];
            final stat = stats[index];
            return _buildStatCard(
                stat['title'] as String,
                stat['value'] as String,
                stat['icon'] as IconData,
                stat['color'] as Color);
          },
        ),
        const SizedBox(height: 24),
        Text('Aktivitas Terbaru',
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildActivityItem('Surat masuk dari PT. ABC',
                    '5 menit yang lalu', 'Baru', posBlue), // ✅ Diubah ke Biru
                const Divider(height: 24),
                _buildActivityItem('Surat keluar ke Divisi IT',
                    '1 jam yang lalu', 'Terkirim', Colors.green),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.grey[600], fontSize: 15)),
                const SizedBox(height: 8),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(time,
                  style: GoogleFonts.poppins(
                      color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20)),
          child: Text(status,
              style: GoogleFonts.poppins(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildKelolaUserContent({required bool isMobile}) {
    final users = [
      {
        'nama': 'Budi Santoso',
        'email': 'budi@posindo.co.id',
        'role': 'Staff',
        'divisi': 'IT'
      },
      {
        'nama': 'Siti Nurhaliza',
        'email': 'siti@posindo.co.id',
        'role': 'Manager',
        'divisi': 'Finance'
      },
      {
        'nama': 'Ahmad Rizki',
        'email': 'ahmad@posindo.co.id',
        'role': 'Staff',
        'divisi': 'Operations'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kelola User',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Tambah User'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: posOrange), // ✅ Diubah ke Oranye
              )
            ],
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                dataRowHeight: 60,
                columns: const [
                  DataColumn(label: Text('NAMA')),
                  DataColumn(label: Text('EMAIL')),
                  DataColumn(label: Text('ROLE')),
                  DataColumn(label: Text('DIVISI')),
                  DataColumn(label: Text('AKSI')),
                ],
                rows: users
                    .map((user) => DataRow(cells: [
                          DataCell(Text(user['nama']!)),
                          DataCell(Text(user['email']!)),
                          DataCell(_buildRoleChip(user['role']!)),
                          DataCell(Text(user['divisi']!)),
                          DataCell(Row(children: [
                            IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: posBlue,
                                tooltip: 'Edit',
                                onPressed: () {}),
                            IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: posRed, // ✅ Hapus tetap merah
                                tooltip: 'Hapus',
                                onPressed: () {}),
                          ])),
                        ]))
                    .toList(),
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
      child: Text(role,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
            if (!isMobile)
              Text('Kelola Divisi',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showTambahDivisiDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah Divisi'),
              style: ElevatedButton.styleFrom(backgroundColor: posOrange), // ✅ Diubah ke Oranye
            )
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                dataRowHeight: 60,
                columns: const [
                  DataColumn(label: Text('NAMA DIVISI')),
                  DataColumn(label: Text('KODE')),
                  DataColumn(label: Text('TELEPON')),
                  DataColumn(label: Text('AKSI')),
                ],
                rows: depts
                    .map((dept) => DataRow(cells: [
                          DataCell(Text(dept['nama']!)),
                          DataCell(Text(dept['kode']!)),
                          DataCell(Text(dept['telepon']!)),
                          DataCell(Row(children: [
                            IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: posBlue,
                                onPressed: () {}),
                            IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: posRed, // ✅ Hapus tetap merah
                                onPressed: () {}),
                          ])),
                        ]))
                    .toList(),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tambah Divisi',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: posBlue)),
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
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: Colors.grey[700])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: posOrange), // ✅ Diubah ke Oranye
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}