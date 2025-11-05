// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// Import dari project Anda
import '../models/surat.dart';
import '../services/database_service.dart';
import '../widgets/section_header.dart';
import '../widgets/surat_card.dart';
import 'add_edit_surat_pages.dart';
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'surat_rangkuman_page.dart';
import 'tracking_page.dart' hide Surat;

// Import halaman dashboard kurir
import 'dashboard/kurir_dashboard.dart';
import 'qr_scanner_page.dart'; // Import untuk scanner kurir

//====================================================================//
//                        KELAS BANTUAN (BerandaContent)
//====================================================================//

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });
}

//====================================================================//
//                        KONTEN TAB BERANDA (PENGIRIM)
//====================================================================//

class BerandaContent extends StatelessWidget {
  final Function(int, {int subTabIndex}) onNavigateToTab;
  const BerandaContent({super.key, required this.onNavigateToTab});

  static const Color posOrange = Color(0xFFF37021);
  static const Color posBlue = Color(0xFF00529C);

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    final List<QuickAction> actions = [
      QuickAction(
        title: 'Kirim Surat', subtitle: 'Kirim surat baru', icon: Icons.add_circle_outline,
        color1: const Color(0xFFF37021), color2: const Color(0xFFFF9A57),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage())),
      ),
      QuickAction(
        title: 'Tracking Surat', subtitle: 'Lacak posisi surat', icon: Icons.travel_explore_rounded,
        color1: const Color(0xFF23B66F), color2: const Color(0xFF56E09A),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackingPage())),
      ),
      QuickAction(
        title: 'Surat Masuk', subtitle: 'Lihat kotak masuk', icon: Icons.inbox_outlined,
        color1: const Color(0xFF00529C), color2: const Color(0xFF4B89DA),
        onTap: () => onNavigateToTab(1, subTabIndex: 0),
      ),
      QuickAction(
        title: 'Surat Keluar', subtitle: 'Lihat surat terkirim', icon: Icons.send_outlined,
        color1: const Color(0xFFE55A34), color2: const Color(0xFFF58A6E),
        onTap: () => onNavigateToTab(1, subTabIndex: 1),
      ),
    ];

    return StreamBuilder<List<Surat>>(
      stream: db.getSuratList(),
      builder: (context, snapshot) {
        final suratList = snapshot.data ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aksi Cepat',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              AnimationLimiter(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: actions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 2,
                      duration: const Duration(milliseconds: 475),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _quickActionCard(action.icon, action.title, action.subtitle, action.color1, action.color2, action.onTap),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Statistik',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.8, 
                children: [
                  _statCard('Surat Masuk', '1', posBlue),
                  _statCard('Surat Keluar', '1', posOrange),
                  _statCard('Pending', '1', Colors.amber.shade700),
                  _statCard('Selesai', '1', Colors.green.shade600),
                ],
              ),
              const SizedBox(height: 28),
              const SectionHeader(
                  title: '📂 Surat Terbaru',
                  actionLabel: 'Lihat Semua',
                  onAction: null),
              const SizedBox(height: 8),
              if (suratList.isEmpty)
                const Center(child: Text('Belum ada surat.'))
              else
                ListView.separated(
                  itemCount: suratList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => SuratCard(surat: suratList[index]),
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionCard(IconData icon, String title, String subtitle, Color color1, Color color2, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color1, color2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color indicatorColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Expanded( 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold,
                        color: indicatorColor,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//====================================================================//
//                HALAMAN UTAMA (STATEFUL WIDGET SHELL)
//====================================================================//

class HomePage extends StatefulWidget {
  // ✅ Menerima 'role' sebagai String, bukan 'isKurir'
  final String role;
  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _initialSuratTabIndex = 0;

  static const Color posOrange = Color(0xFFF37021);
  static const Color posBlue = Color(0xFF00529C);

  void _onItemTapped(int index) {
    setState(() {
      if (index != 1) _initialSuratTabIndex = 0;
      _selectedIndex = index;
    });
  }
  
  // ✅ Fungsi 'onNavigateToTab' untuk 'BerandaContent'
  void _navigateToSuratTab(int index, {int subTabIndex = 0}) {
    setState(() {
      _selectedIndex = index;
      _initialSuratTabIndex = subTabIndex;
    });
  }

  void _openScanner() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerPage()));
  }

  // ✅ Fungsi untuk memilih dashboard yang benar
  Widget _getDashboardForRole() {
    switch (widget.role) {
      case 'kurir':
        return const KurirDashboard();
      case 'pengirim':
        return BerandaContent(onNavigateToTab: _navigateToSuratTab);
      case 'penerima':
        // TODO: Ganti ini dengan PenerimaDashboard jika sudah ada
        return const Center(child: Text("Ini Dashboard Penerima")); 
      default:
        return const Center(child: Text('Peran tidak dikenal'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _getDashboardForRole(), // ✅ Memanggil dashboard yang sesuai
      SuratRangkumanPage(initialTabIndex: _initialSuratTabIndex),
      const NotifikasiPage(),
      const ProfilPage(),
    ];

    bool isKurir = widget.role == 'kurir';

    // Tampilan untuk Kurir
    if (isKurir) {
      return Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: _buildCourierNavBar(),
        floatingActionButton: _buildCourierFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }

    // Tampilan untuk Pengirim (biasa)
    String appBarTitle;
    switch (_selectedIndex) {
      case 1: appBarTitle = 'Rangkuman Surat'; break;
      case 2: appBarTitle = 'Notifikasi'; break;
      case 3: appBarTitle = 'Profil Saya'; break;
      default: appBarTitle = 'mailingroom';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selectedIndex == 0)
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo_pos.png', // ✅ Pastikan path logo benar
                          height: 35.0,
                          errorBuilder: (c, e, s) => const Icon(Icons.all_inbox),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Mailingroom",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      appBarTitle,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _onItemTapped(2),
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _onItemTapped(3),
                        borderRadius: BorderRadius.circular(20),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: posBlue,
                          child: Icon(Icons.person,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: _buildRegularNavBar(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditSuratPage(),
                  ),
                );
              },
              backgroundColor: posOrange,
              tooltip: 'Tambah Surat',
              child: const Icon(Icons.add, color: Colors.white,),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- Helper Widgets untuk Navigasi ---

  Widget _buildRegularNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: posBlue,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined), label: 'Surat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }

  Widget _buildCourierFAB() {
    return FloatingActionButton(
      onPressed: _openScanner,
      backgroundColor: posOrange,
      elevation: 4.0,
      shape: const CircleBorder(),
      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
    );
  }
  
  Widget _buildCourierNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavBarItem(icon: Icons.home_outlined, label: 'Beranda', index: 0),
          _buildNavBarItem(icon: Icons.article_outlined, label: 'Surat', index: 1),
          const SizedBox(width: 40),
          _buildNavBarItem(icon: Icons.notifications_none, label: 'Notifikasi', index: 2, hasBadge: true, badgeCount: 3),
          _buildNavBarItem(icon: Icons.person_outline, label: 'Profil', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({required IconData icon, required String label, required int index, bool hasBadge = false, int badgeCount = 0}) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: isSelected ? posOrange : Colors.grey[600]),
                  if (hasBadge)
                    Positioned(
                      top: -4, right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(badgeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isSelected ? posOrange : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}