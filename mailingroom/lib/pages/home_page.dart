// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart'; // ✅ Import model user

// Import semua halaman
import 'dashboard/kurir_dashboard.dart';
import 'dashboard/pengirim_dashboard.dart';
// import 'dashboard/penerima_dashboard.dart'; // Buat file ini
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'surat_rangkuman_page.dart';
import 'add_edit_surat_pages.dart';


class HomePage extends StatefulWidget {
  // ✅ PERBAIKAN: Terima 'MyUser' bukan 'String role'
  final MyUser user; 
  const HomePage({super.key, required this.user});

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

  void _navigateToSuratTab(int subTabIndex) {
    setState(() {
      _selectedIndex = 1;
      _initialSuratTabIndex = subTabIndex;
    });
  }

  // Fungsi untuk memilih dashboard yang benar
  Widget _getDashboardForRole() {
    switch (widget.user.role) {
      case 'kurir':
        // ✅ Kirim 'user' ke KurirDashboard
        return KurirDashboard(user: widget.user); 
      case 'pengirim':
        // ✅ Kirim 'user' ke PengirimDashboard
        return PengirimDashboard(user: widget.user, onNavigateToTab: (index, {subTabIndex = 0}) => _navigateToSuratTab(subTabIndex));
      case 'penerima':
        // TODO: Ganti ini dengan PenerimaDashboard jika sudah ada
        return Center(child: Text("Ini Dashboard Penerima: ${widget.user.nama}")); 
      default:
        return const Center(child: Text('Peran tidak dikenal'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      _getDashboardForRole(),
      SuratRangkumanPage(initialTabIndex: _initialSuratTabIndex),
      const NotifikasiPage(),
      ProfilPage(user: widget.user), // ✅ Kirim user ke ProfilPage
    ];
    
    bool isKurir = widget.user.role == 'kurir';
    
    if (isKurir) {
      return Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: _buildCourierNavBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }

    // Tampilan untuk Pengirim / Penerima
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _selectedIndex == 0 ? PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          titleSpacing: 16.0,
          title: Row(
              children: [
                Image.asset('assets/images/logo_pos.png', height: 35.0, errorBuilder: (c,e,s) => const Icon(Icons.all_inbox)),
                const SizedBox(width: 12),
                Text("Mailingroom", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          actions: [
            IconButton(
              onPressed: () => _onItemTapped(2),
              icon: const Icon(Icons.notifications_none, color: Colors.black54),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: InkWell(
                onTap: () => _onItemTapped(3),
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: posBlue,
                  // ✅ PERBAIKAN: Tampilkan inisial nama
                  child: Text(
                    widget.user.nama.isNotEmpty ? widget.user.nama[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ) : null,
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: _buildRegularNavBar(),
      floatingActionButton: _selectedIndex == 0 ? _buildRegularFAB() : null,
    );
  }
  
  Widget _buildRegularNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: posBlue,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Surat'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }

  Widget _buildRegularFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage()));
      },
      backgroundColor: posOrange,
      tooltip: 'Kirim Surat',
      child: const Icon(Icons.add, color: Colors.white),
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

  // ✅ PERBAIKAN OVERFLOW 4.0 PIXEL
  Widget _buildNavBarItem({required IconData icon, required String label, required int index, bool hasBadge = false, int badgeCount = 0}) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          // Kurangi padding vertikal
          padding: const EdgeInsets.symmetric(vertical: 6.0), 
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
              // Kurangi spasi
              const SizedBox(height: 2), 
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