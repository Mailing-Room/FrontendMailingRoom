import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/auth/auth_service.dart';

// Import Model
import '../../models/office.dart';
import '../../models/subdirektorat.dart'; 
import '../../models/user.dart'; 

enum AdminPage { dashboard, kelolaSurat, kelolaUser, kelolaDivisi, kelolaOffice, cetakLaporan }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  AdminPage _selectedPage = AdminPage.dashboard;
  bool _isSidebarExpanded = false;

  // Warna tema
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);
  final Color posRed = const Color(0xFFC62828);
  final Color lightBg = const Color(0xFFF5F7FA);

  // State untuk Data User (agar bisa di-refresh)
  late Future<List<MyUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers(); // Load data awal
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = Provider.of<AuthService>(context, listen: false).getAllUsers();
    });
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
        if (!isMobile) _isSidebarExpanded = true;

        // Desktop View
        if (!isMobile) {
          return Scaffold(
            backgroundColor: lightBg,
            body: Row(
              children: [
                _buildSideBar(context, isMobile: false),
                Expanded(child: _buildMainContent(isMobile: false)),
              ],
            ),
          );
        }

        // Mobile View
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: lightBg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1.0,
              title: Text(_getPageTitle(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  FocusScope.of(context).unfocus();
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
                  _buildSideBar(context, isMobile: true),
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
      case AdminPage.kelolaOffice: return 'Kelola Office';
      case AdminPage.cetakLaporan: return 'Cetak Laporan';
    }
  }
  
  Widget _buildSideBar(BuildContext context, {required bool isMobile}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isSidebarExpanded ? 250 : (isMobile ? 0 : 70),
      color: posBlue, 
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_pos.png', height: 32, errorBuilder: (c,e,s) => const Icon(Icons.mark_email_read, color: Colors.white, size: 32)),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pos Indonesia', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Admin Panel', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1, indent: 16, endIndent: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSideBarItem(context: context, title: 'Dashboard', icon: Icons.dashboard_outlined, page: AdminPage.dashboard, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola Surat', icon: Icons.drafts_outlined, page: AdminPage.kelolaSurat, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola User', icon: Icons.people_outline, page: AdminPage.kelolaUser, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola Divisi', icon: Icons.business_outlined, page: AdminPage.kelolaDivisi, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Kelola Office', icon: Icons.location_city_outlined, page: AdminPage.kelolaOffice, isMobile: isMobile),
                  _buildSideBarItem(context: context, title: 'Cetak Laporan', icon: Icons.print_outlined, page: AdminPage.cetakLaporan, isMobile: isMobile),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white24, height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),
          _buildSideBarItem(context: context, title: 'Logout', icon: Icons.logout, page: null, isLogout: true, isMobile: isMobile),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSideBarItem({required BuildContext context, required String title, required IconData icon, required bool isMobile, AdminPage? page, bool isLogout = false}) {
    final bool isSelected = _selectedPage == page;
    return InkWell(
      onTap: () {
        if (isLogout) {
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
    switch (_selectedPage) {
      case AdminPage.dashboard:
        return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 16 : 32), child: _buildDashboardContent(isMobile: isMobile));
      case AdminPage.kelolaSurat:
        return const Center(child: Text("Fitur Kelola Surat"));
      case AdminPage.kelolaUser:
        return SingleChildScrollView(padding: EdgeInsets.all(isMobile ? 16 : 32), child: _buildKelolaUserContent(isMobile: isMobile));
      case AdminPage.kelolaDivisi:
        return const Center(child: Text("Fitur Kelola Divisi"));
      case AdminPage.kelolaOffice:
        return const Center(child: Text("Fitur Kelola Office"));
      case AdminPage.cetakLaporan:
        return Center(child: Text('Halaman Cetak Laporan', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)));
    }
  }

  Widget _buildDashboardContent({required bool isMobile}) {
    final List<Map<String, dynamic>> stats = [
      {'title': 'Total Surat Keluar', 'value': '0', 'icon': Icons.mail_outline, 'color': Colors.green},
      {'title': 'Total User', 'value': '0', 'icon': Icons.people_alt_outlined, 'color': posBlue},
      {'title': 'Total Divisi', 'value': '0', 'icon': Icons.business_center_outlined, 'color': posOrange},
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
                          Text(stat['title'], style: GoogleFonts.poppins(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(stat['value'], style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: (stat['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Icon(stat['icon'], color: stat['color'], size: 28),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKelolaUserContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isMobile) Text('Kelola User', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => _showUserFormDialog(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah User'),
              style: ElevatedButton.styleFrom(backgroundColor: posOrange, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 20),
        
        FutureBuilder<List<MyUser>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Gagal memuat data user: ${snapshot.error}"));
            }
            
            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text("Belum ada data user", style: GoogleFonts.poppins(color: Colors.grey)),
              ));
            }

            return SizedBox(
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
                      columns: const [
                        DataColumn(label: Text('NAMA')),
                        DataColumn(label: Text('EMAIL')),
                        DataColumn(label: Text('ROLE')),
                        DataColumn(label: Text('AKSI')),
                      ],
                      rows: users.map((user) => DataRow(cells: [
                        DataCell(Text(user.nama, style: GoogleFonts.poppins())),
                        DataCell(Text(user.email, style: GoogleFonts.poppins())),
                        DataCell(_buildRoleChip(user.role)),
                        DataCell(Row(children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined), 
                            color: posBlue, 
                            tooltip: 'Edit User',
                            onPressed: () => _showUserFormDialog(user: user)
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline), 
                            color: posRed, 
                            tooltip: 'Hapus User',
                            onPressed: () => _confirmDeleteUser(user)
                          ),
                        ])),
                      ])).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role.toLowerCase()) {
      case 'admin': color = posOrange; break;
      case 'kurir': color = Colors.green; break;
      default: color = posBlue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(role.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // --- DIALOG FORM (CREATE / UPDATE) DENGAN PERBAIKAN CONTEXT ---
  void _showUserFormDialog({MyUser? user}) async {
    final isEdit = user != null;
    
    final nameController = TextEditingController(text: isEdit ? user.nama : '');
    final emailController = TextEditingController(text: isEdit ? user.email : '');
    final passwordController = TextEditingController();

    String? selectedRole = isEdit ? user.role : null;
    String? selectedOfficeId = isEdit ? user.officeId : null;
    String? selectedSubDirektoratId = isEdit ? user.divisiId : null; 

    final authService = Provider.of<AuthService>(context, listen: false);
    List<Office> offices = [];
    List<SubDirektorat> subDirektorats = [];

    try {
      offices = await authService.getOffices();
      subDirektorats = await authService.getSubDirektorats();
    } catch (e) { print("Gagal load master data: $e"); }

    // Gunakan 'mounted' check di dalam async jika perlu, 
    // tapi karena showDialog akan membuka konteks baru, kita aman di sini.
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) { // Ubah nama jadi dialogContext agar tidak bingung
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEdit ? 'Edit User' : 'Tambah User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: isEdit ? 'Password (Kosongkan jika tidak diubah)' : 'Password',
                          border: const OutlineInputBorder()
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                        items: ['admin', 'kurir', 'user', 'penerima'].map((role) {
                          return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => selectedRole = val),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedOfficeId,
                        decoration: const InputDecoration(labelText: 'Kantor / Office', border: OutlineInputBorder()),
                        items: offices.map((office) {
                          return DropdownMenuItem(value: office.id, child: Text(office.namaOffice));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => selectedOfficeId = val),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedSubDirektoratId,
                        decoration: const InputDecoration(labelText: 'Sub Direktorat', border: OutlineInputBorder()),
                        items: subDirektorats.map((sub) {
                          return DropdownMenuItem(value: sub.id, child: Text(sub.nama));
                        }).toList(),
                        onChanged: (val) => setStateDialog(() => selectedSubDirektoratId = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), 
                  child: Text('Batal', style: TextStyle(color: Colors.grey[700]))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: posOrange, foregroundColor: Colors.white),
                  onPressed: () async {
                    // Validasi Sederhana
                    if (nameController.text.isEmpty || emailController.text.isEmpty || selectedRole == null) {
                      // Gunakan dialogContext jika snackbar ingin muncul di atas dialog (jarang), 
                      // atau gunakan ScaffoldMessenger dengan context utama jika dialog sudah ditutup.
                      // Tapi kita akan tutup dialog dulu.
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Nama, Email, dan Role wajib diisi')));
                      return;
                    }

                    // --- PERBAIKAN UTAMA DI SINI ---
                    // 1. Simpan referensi ScaffoldMessenger sebelum pop dan await
                    final messenger = ScaffoldMessenger.of(this.context);

                    // 2. Tutup Dialog
                    Navigator.pop(dialogContext); 
                    
                    try {
                      // 3. Proses Async
                      if (isEdit) {
                        final Map<String, dynamic> updateData = {
                           'name': nameController.text,
                           'email': emailController.text,
                           'role_id': selectedRole,
                           'office_id': selectedOfficeId ?? '',
                           'sub_direktorat_id': selectedSubDirektoratId ?? '',
                        };
                        if (passwordController.text.isNotEmpty) {
                           updateData['password'] = passwordController.text;
                        }
                        
                        await authService.updateUser(user.uid, updateData);
                        // 4. Gunakan variabel messenger
                        messenger.showSnackBar(const SnackBar(content: Text('User berhasil diperbarui'), backgroundColor: Colors.green));
                      } else {
                        await authService.addUser(
                          email: emailController.text,
                          password: passwordController.text,
                          name: nameController.text,
                          role: selectedRole!,
                          officeId: selectedOfficeId,
                          subDirektoratId: selectedSubDirektoratId,
                        );
                         messenger.showSnackBar(const SnackBar(content: Text('User berhasil ditambahkan'), backgroundColor: Colors.green));
                      }
                      
                      _refreshUsers(); 
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG HAPUS USER DENGAN PERBAIKAN CONTEXT ---
  void _confirmDeleteUser(MyUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus User"),
        content: Text("Apakah Anda yakin ingin menghapus user ${user.nama}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: posRed, foregroundColor: Colors.white),
            onPressed: () async {
              // --- PERBAIKAN: Tangkap Messenger ---
              final messenger = ScaffoldMessenger.of(context);
              
              // Tutup Dialog
              Navigator.pop(dialogContext);

              try {
                await Provider.of<AuthService>(context, listen: false).deleteUser(user.uid);
                messenger.showSnackBar(const SnackBar(content: Text('User berhasil dihapus'), backgroundColor: Colors.green));
                _refreshUsers(); 
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}