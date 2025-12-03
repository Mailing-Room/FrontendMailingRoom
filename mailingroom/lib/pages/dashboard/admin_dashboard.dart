import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mailingroom/auth/auth_service.dart';
import 'package:mailingroom/providers/surat_provider.dart';

// Import Model
import '../../models/surat.dart';
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
  bool _isSidebarExpanded = false; // Default tertutup di mobile

  // Warna tema
  final Color posOrange = const Color(0xFFF37021);
  final Color posBlue = const Color(0xFF00529C);
  final Color posRed = const Color(0xFFC62828);
  final Color lightBg = const Color(0xFFF5F7FA);

  // State untuk Data User
  late Future<List<MyUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers(); 
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

  // Mengambil data statistik real-time
  Future<Map<String, int>> _fetchDashboardStats() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final suratProvider = Provider.of<SuratProvider>(context, listen: false);

    try {
      final results = await Future.wait([
        authService.getAllUsers(),
        authService.getOffices(),
        authService.getSubDirektorats(),
        suratProvider.allSuratStream.first, 
      ]);

      final users = results[0] as List<MyUser>;
      final offices = results[1] as List<Office>;
      final subDirs = results[2] as List<SubDirektorat>;
      final surat = results[3] as List<Surat>;

      return {
        'users': users.length,
        'offices': offices.length,
        'divisi': subDirs.length,
        'surat': surat.length,
      };
    } catch (e) {
      // Fallback jika error
      return {'users': 0, 'offices': 0, 'divisi': 0, 'surat': 0};
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 1000; // Breakpoint untuk tablet/desktop
        
        // Di desktop, sidebar default terbuka
        if (!isMobile && !_isSidebarExpanded) {
          // Kita tidak set state di build, tapi inisialisasi awal bisa diatur di initState jika mau
          // Di sini kita biarkan user mengontrol atau default terbuka
        }

        return Scaffold(
          backgroundColor: lightBg,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SIDEBAR (Responsive)
              if (!isMobile) 
                _buildSideBar(context, isMobile: false),

              // MAIN CONTENT
              Expanded(
                child: Scaffold(
                  backgroundColor: lightBg,
                  // AppBar hanya muncul di Mobile atau jika sidebar tertutup
                  appBar: isMobile 
                    ? AppBar(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        centerTitle: true,
                        title: Text("Admin Panel", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: posBlue)),
                        leading: IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            // Buka Drawer di Mobile
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      )
                    : null,
                  drawer: isMobile ? Drawer(child: _buildSideBar(context, isMobile: true)) : null,
                  body: _buildMainContent(isMobile: isMobile),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Key untuk mengontrol drawer di mobile
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- SIDEBAR ---
  Widget _buildSideBar(BuildContext context, {required bool isMobile}) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          // Header Logo
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: posBlue,
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Image.asset('assets/images/logo_pos.png', height: 30, errorBuilder: (c,e,s) => Icon(Icons.mark_email_read, color: posOrange)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('POS IND', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Admin Dashboard', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuLabel("MENU UTAMA"),
                  _buildSideBarItem(title: 'Dashboard', icon: Icons.grid_view_rounded, page: AdminPage.dashboard),
                  _buildSideBarItem(title: 'Kelola Surat', icon: Icons.mark_email_unread_rounded, page: AdminPage.kelolaSurat),
                  
                  const SizedBox(height: 20),
                  _buildMenuLabel("MASTER DATA"),
                  _buildSideBarItem(title: 'Kelola User', icon: Icons.people_alt_rounded, page: AdminPage.kelolaUser),
                  _buildSideBarItem(title: 'Kelola Divisi', icon: Icons.domain_rounded, page: AdminPage.kelolaDivisi),
                  _buildSideBarItem(title: 'Kelola Office', icon: Icons.location_city_rounded, page: AdminPage.kelolaOffice),
                  
                  const SizedBox(height: 20),
                  _buildMenuLabel("LAPORAN"),
                  _buildSideBarItem(title: 'Cetak Laporan', icon: Icons.print_rounded, page: AdminPage.cetakLaporan),
                ],
              ),
            ),
          ),

          // Footer Logout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSideBarItem(title: 'Logout', icon: Icons.logout_rounded, page: null, isLogout: true, isMobile: isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSideBarItem({required String title, required IconData icon, AdminPage? page, bool isLogout = false, bool isMobile = false}) {
    final bool isSelected = _selectedPage == page && !isLogout;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLogout) {
            Provider.of<AuthService>(context, listen: false).signOut();
          } else if (page != null) {
            setState(() {
              _selectedPage = page;
            });
            if (isMobile) Navigator.pop(context); // Tutup drawer di mobile
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected ? posBlue.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: posBlue.withOpacity(0.1)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? posBlue : Colors.grey[500], size: 22),
              const SizedBox(width: 12),
              Text(
                title, 
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? posBlue : Colors.grey[700], 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent({required bool isMobile}) {
    switch (_selectedPage) {
      case AdminPage.dashboard:
        return SingleChildScrollView(padding: EdgeInsets.only(bottom: 100), child: _buildDashboardContent(isMobile: isMobile));
      case AdminPage.kelolaSurat:
        return const Center(child: Text("Fitur Kelola Surat"));
      case AdminPage.kelolaUser:
        return SingleChildScrollView(padding: EdgeInsets.only(bottom: 100), child: _buildKelolaUserContent(isMobile: isMobile));
      case AdminPage.kelolaDivisi:
        return SingleChildScrollView(padding: EdgeInsets.only(bottom: 100), child: _buildKelolaDivisiContent(isMobile: isMobile));
      case AdminPage.kelolaOffice:
        return SingleChildScrollView(padding: EdgeInsets.only(bottom: 100), child: _buildKelolaOfficeContent(isMobile: isMobile));
      case AdminPage.cetakLaporan:
        return Center(child: Text('Halaman Cetak Laporan', style: GoogleFonts.plusJakartaSans(fontSize: 24)));
    }
  }

  // --- KONTEN DASHBOARD PREMIUM ---
  Widget _buildDashboardContent({required bool isMobile}) {
    return Column(
      children: [
        // 1. Header Banner
        _buildHeaderBanner("Dashboard Overview", "Ringkasan aktivitas sistem Mailing Room."),

        // 2. Konten Utama (Statistik & Aksi Cepat)
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<Map<String, int>>(
            future: _fetchDashboardStats(),
            builder: (context, snapshot) {
              int totalUser = 0;
              int totalSurat = 0;
              int totalDivisi = 0;
              int totalOffice = 0;

              if (snapshot.hasData) {
                totalUser = snapshot.data!['users'] ?? 0;
                totalSurat = snapshot.data!['surat'] ?? 0;
                totalDivisi = snapshot.data!['divisi'] ?? 0;
                totalOffice = snapshot.data!['offices'] ?? 0;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN 1: STATISTIK ---
                  _buildSectionTitle("Statistik"),
                  const SizedBox(height: 16),
                  
                  // Gunakan WRAP agar responsif dan tidak overflow
                  LayoutBuilder(builder: (context, constraints) {
                     // Logic lebar kartu agar responsif
                     double cardWidth = (constraints.maxWidth - 20) / 2; // Default 2 kolom
                     if (constraints.maxWidth > 900) cardWidth = (constraints.maxWidth - 45) / 4; // 4 kolom di layar lebar
                     
                     return Wrap(
                       spacing: 15,
                       runSpacing: 15,
                       children: [
                         _buildStatCard("Total User", totalUser.toString(), Icons.people_alt_rounded, Colors.blue, width: cardWidth),
                         _buildStatCard("Total Surat", totalSurat.toString(), Icons.mark_email_read_rounded, Colors.green, width: cardWidth),
                         _buildStatCard("Total Divisi", totalDivisi.toString(), Icons.domain_rounded, Colors.orange, width: cardWidth),
                         _buildStatCard("Total Office", totalOffice.toString(), Icons.location_city_rounded, Colors.purple, width: cardWidth),
                       ],
                     );
                  }),

                  const SizedBox(height: 32),

                  // --- BAGIAN 2: AKSI CEPAT ---
                  _buildSectionTitle("Aksi Cepat"),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionCard("Tambah User", Icons.person_add_rounded, Colors.blue, () => _showUserFormDialog()),
                      _buildActionCard("Tambah Surat", Icons.post_add_rounded, posOrange, () {}), 
                      _buildActionCard("Tambah Divisi", Icons.add_business_rounded, Colors.purple, () {}), 
                      _buildActionCard("Buat Laporan", Icons.print_rounded, Colors.teal, () {}), 
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --- HEADER PAGE BANNER ---
  Widget _buildHeaderBanner(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));

  // --- KARTU STATISTIK PREMIUM ---
  Widget _buildStatCard(String title, String count, IconData icon, Color color, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      // Clip untuk memotong dekorasi icon
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Dekorasi Icon Besar Pudar
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 80, color: color.withOpacity(0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(count, style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // --- KARTU AKSI CEPAT ---
  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150, // Fixed width for action buttons
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 24, child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  // --- HALAMAN DAFTAR USER / OFFICE / DIVISI (Tabel) ---
  Widget _buildKelolaUserContent({required bool isMobile}) {
    return Column(
      children: [
        _buildHeaderBanner("Manajemen User", "Kelola data pengguna, role, dan akses."),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showUserFormDialog(), 
                    icon: const Icon(Icons.add), 
                    label: const Text("Tambah User"),
                    style: ElevatedButton.styleFrom(backgroundColor: posOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              _buildUserTable(),
            ],
          ),
        )
      ],
    );
  }
  
  Widget _buildKelolaOfficeContent({required bool isMobile}) {
     return Column(
      children: [
        _buildHeaderBanner("Manajemen Kantor", "Daftar lokasi kantor dan cabang."),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _buildOfficeTable(), // Gunakan helper table
        )
      ]
     );
  }
  
  Widget _buildKelolaDivisiContent({required bool isMobile}) {
     return Column(
      children: [
        _buildHeaderBanner("Manajemen Divisi", "Daftar divisi dan sub-direktorat."),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _buildDivisiTable(), // Gunakan helper table
        )
      ]
     );
  }

  // --- HELPERS UNTUK TABEL ---
  Widget _buildUserTable() {
    return FutureBuilder<List<MyUser>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data ?? [];
        if (users.isEmpty) return _buildEmptyState("Belum ada user");

        return _buildDataTableWrapper(
          columns: ['Nama', 'Email', 'Role', 'Aksi'],
          rows: users.map((user) => DataRow(cells: [
            DataCell(Text(user.nama, style: GoogleFonts.plusJakartaSans())),
            DataCell(Text(user.email, style: GoogleFonts.plusJakartaSans())),
            DataCell(_buildRoleChip(user.role)),
            DataCell(Row(children: [
              IconButton(icon: const Icon(Icons.edit_outlined, size: 20), color: posBlue, onPressed: () => _showUserFormDialog(user: user)),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20), color: posRed, onPressed: () => _confirmDeleteUser(user)),
            ])),
          ])).toList(),
        );
      },
    );
  }
  
  Widget _buildOfficeTable() {
    return FutureBuilder<List<Office>>(
        future: Provider.of<AuthService>(context, listen: false).getOffices(),
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
           final offices = snapshot.data ?? [];
           if (offices.isEmpty) return _buildEmptyState("Belum ada data office");

           return _buildDataTableWrapper(
             columns: ['Nama Office', 'Kota', 'Alamat', 'Aksi'],
             rows: offices.map((office) => DataRow(cells: [
               DataCell(Text(office.namaOffice)),
               DataCell(Text(office.kota)),
               DataCell(Text(office.alamat, overflow: TextOverflow.ellipsis)),
               DataCell(Row(children: [
                 IconButton(icon: const Icon(Icons.edit_outlined, size: 20), color: posBlue, onPressed: () {}),
                 IconButton(icon: const Icon(Icons.delete_outline, size: 20), color: posRed, onPressed: () {}),
               ])),
             ])).toList()
           );
        },
    );
  }
  
  Widget _buildDivisiTable() {
    return FutureBuilder<List<SubDirektorat>>(
        future: Provider.of<AuthService>(context, listen: false).getSubDirektorats(),
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
           final subs = snapshot.data ?? [];
           if (subs.isEmpty) return _buildEmptyState("Belum ada data divisi");

           return _buildDataTableWrapper(
             columns: ['Nama Divisi', 'Kode', 'Aksi'],
             rows: subs.map((sub) => DataRow(cells: [
               DataCell(Text(sub.nama)),
               DataCell(Text(sub.kode)),
               DataCell(Row(children: [
                 IconButton(icon: const Icon(Icons.edit_outlined, size: 20), color: posBlue, onPressed: () {}),
                 IconButton(icon: const Icon(Icons.delete_outline, size: 20), color: posRed, onPressed: () {}),
               ])),
             ])).toList()
           );
        },
    );
  }

  Widget _buildDataTableWrapper({required List<String> columns, required List<DataRow> rows}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade100),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          headingTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          dataTextStyle: GoogleFonts.plusJakartaSans(color: Colors.black87),
          columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
          rows: rows,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(String msg) {
     return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(
       children: [
         Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade300),
         const SizedBox(height: 12),
         Text(msg, style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
       ],
     )));
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role.toLowerCase()) { case 'admin': color = posOrange; break; case 'kurir': color = Colors.green; break; default: color = posBlue; }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(role.toUpperCase(), style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.bold, fontSize: 11)));
  }

  // --- DIALOG FORM & DELETE (Sama seperti sebelumnya, copy paste saja bagian ini) ---
  void _showUserFormDialog({MyUser? user}) async {
     // ... (Gunakan kode dialog dari respons "Admin Dashboard (CRUD User)" sebelumnya)
     // Agar kode tidak terlalu panjang di sini, logika dialognya sama persis.
     // Pastikan menggunakan 'mounted' check dan ScaffoldMessenger yang aman.
     
     // --- RECAP SINGKAT LOGIKA DIALOG ---
     // 1. Init Controllers
     // 2. Fetch Offices & SubDirs
     // 3. if (!mounted) return;
     // 4. showDialog -> StatefulBuilder
     // 5. ElevatedButton onPressed -> Validasi -> final messenger = ScaffoldMessenger.of(this.context); -> Navigator.pop -> await authService... -> messenger.showSnackBar
     
     // Kode lengkap dialog sudah ada di file sebelumnya, silakan integrasikan.
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

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) { 
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
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: passwordController, decoration: InputDecoration(labelText: isEdit ? 'Password (Kosongkan jika tidak diubah)' : 'Password', border: const OutlineInputBorder()), obscureText: true),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                        items: ['admin', 'kurir', 'user', 'penerima'].map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase()))).toList(),
                        onChanged: (val) => setStateDialog(() => selectedRole = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedOfficeId,
                        decoration: const InputDecoration(labelText: 'Kantor / Office', border: OutlineInputBorder()),
                        items: offices.map((office) => DropdownMenuItem(value: office.id, child: Text(office.namaOffice))).toList(),
                        onChanged: (val) => setStateDialog(() => selectedOfficeId = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedSubDirektoratId,
                        decoration: const InputDecoration(labelText: 'Sub Direktorat', border: OutlineInputBorder()),
                        items: subDirektorats.map((sub) => DropdownMenuItem(value: sub.id, child: Text(sub.nama))).toList(),
                        onChanged: (val) => setStateDialog(() => selectedSubDirektoratId = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Batal', style: TextStyle(color: Colors.grey[700]))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: posOrange, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty || selectedRole == null) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Nama, Email, dan Role wajib diisi')));
                      return;
                    }
                    final messenger = ScaffoldMessenger.of(this.context);
                    Navigator.pop(dialogContext); 
                    try {
                      if (isEdit) {
                        final Map<String, dynamic> updateData = {
                           'name': nameController.text,
                           'email': emailController.text,
                           'role_id': selectedRole,
                           'office_id': selectedOfficeId ?? '',
                           'sub_direktorat_id': selectedSubDirektoratId ?? '',
                        };
                        if (passwordController.text.isNotEmpty) updateData['password'] = passwordController.text;
                        await authService.updateUser(user.uid, updateData);
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
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext);
              try {
                await Provider.of<AuthService>(this.context, listen: false).deleteUser(user.uid);
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