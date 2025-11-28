import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart';

// Import halaman
import 'dashboard/kurir_dashboard.dart';
import 'dashboard/pengirim_dashboard.dart';
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'surat_rangkuman_page.dart';
import 'add_edit_surat_pages.dart';

class HomePage extends StatefulWidget {
  final MyUser user; 
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _initialSuratTabIndex = 0;
  
  // Warna Utama
  static const Color posOrange = Color(0xFFF37021);
  static const Color posBlue = Color(0xFF00529C);

  late final List<Widget> _pages;
  
  final List<String> _pageTitles = [
    "Beranda", 
    "Surat",
    "Notifikasi",
    "Profil Saya"
  ];

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _getDashboardForRole(),
      SuratRangkumanPage(initialTabIndex: _initialSuratTabIndex),
      const NotifikasiPage(),
      ProfilPage(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index != 1) _initialSuratTabIndex = 0;
      _selectedIndex = index;
    });
  }

  void _navigateToSuratTab(int subTabIndex) {
    setState(() {
      _selectedIndex = 1;
      _initialSuratTabIndex = subTabIndex;
      _pages[1] = SuratRangkumanPage(initialTabIndex: _initialSuratTabIndex);
    });
  }

  Widget _getDashboardForRole() {
    switch (widget.user.role) { 
      case 'kurir':
        return KurirDashboard(user: widget.user); 
      
      case 'user':
      case 'pengirim':
        return PengirimDashboard(user: widget.user, onNavigateToTab: (index, {subTabIndex = 0}) => _navigateToSuratTab(subTabIndex));

      case 'penerima':
        return Center(child: Text("Ini Dashboard Penerima: ${widget.user.nama}")); 
      
      default:
        return const Center(child: Text('Peran tidak dikenal'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengizinkan body meluas ke belakang navbar agar terlihat transparan/floating
      extendBody: true, 
      backgroundColor: const Color(0xFFF8F9FA),
      
      appBar: _buildAppBar(context, _pageTitles[_selectedIndex]),

      // Menggunakan Stack untuk background decoration (opsional)
      body: Stack(
        children: [
          // Background Gradient Halus (Opsional, agar tidak terlalu polos)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          
          // Konten Utama
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              // Gunakan AnimatedSwitcher untuk animasi transisi antar halaman
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages.elementAt(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
      
      // Navbar Melayang
      bottomNavigationBar: _buildFloatingNavBar(context),
      
      floatingActionButton: _buildFAB(context),
      // Memastikan FAB tidak tertutup navbar melayang
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white,
      // Menghilangkan shadow agar terlihat menyatu dengan background
      elevation: 0, 
      // Garis tipis di bawah AppBar sebagai pemisah
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade200, height: 1.0,),
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 0, 
      centerTitle: true,
      
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _selectedIndex == 0 
              ? Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    // Logo
                    Image.asset('assets/images/logo_pos.png', height: 32.0, errorBuilder: (c,e,s) => const Icon(Icons.all_inbox, color: posOrange)),
                    const SizedBox(width: 12),
                    // Judul dengan Font yang lebih modern
                    Text("Mailingroom", style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                )
              : Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
        ),
      ),
      
      actions: [
        _buildNotificationIcon(context), 
        Padding(
          padding: const EdgeInsets.only(right: 24.0, left: 8.0),
          child: InkWell(
            onTap: () => _onItemTapped(3),
            // Efek splash bulat
            borderRadius: BorderRadius.circular(50), 
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: posBlue.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: posBlue,
                child: Text(
                  widget.user.nama.isNotEmpty ? widget.user.nama[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return IconButton(
      onPressed: () => _onItemTapped(2),
      splashRadius: 24,
      icon: Stack(
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.black54, size: 26),
          // Badge notifikasi (contoh)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          )
        ],
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    if (widget.user.role == 'kurir' || _selectedIndex != 0) return null; 

    // Geser FAB sedikit ke atas agar tidak tertabrak navbar melayang
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0), 
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage()));
        },
        backgroundColor: posOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Kirim Surat',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
  
  // --- NAVBAR MELAYANG (FLOATING) ---
  Widget _buildFloatingNavBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          // Margin agar tidak menempel ke sisi layar (efek melayang)
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0), 
          constraints: const BoxConstraints(maxWidth: 450), // Lebar maksimal navbar
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35), // Membuatnya berbentuk kapsul
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FloatingNavItem(icon: Icons.home_rounded, label: 'Beranda', index: 0, currentIndex: _selectedIndex, onTap: _onItemTapped),
              _FloatingNavItem(icon: Icons.description_rounded, label: 'Surat', index: 1, currentIndex: _selectedIndex, onTap: _onItemTapped),
              _FloatingNavItem(icon: Icons.notifications_rounded, label: 'Notifikasi', index: 2, currentIndex: _selectedIndex, onTap: _onItemTapped),
              _FloatingNavItem(icon: Icons.person_rounded, label: 'Profil', index: 3, currentIndex: _selectedIndex, onTap: _onItemTapped),
            ],
          ),
        ),
      ),
    );
  }
}

// Item Navigasi Kustom dengan Animasi
class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = index == currentIndex;
    final Color posBlue = const Color(0xFF00529C);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? posBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? posBlue : Colors.grey[400],
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: posBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}