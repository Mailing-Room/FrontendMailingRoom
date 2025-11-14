// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailingroom/models/user.dart'; 
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
    });
  }

  
  Widget _getDashboardForRole() {
    switch (widget.user.role) { 
      case 'kurir':
        return Center(child: Text("Ini Dashboard Kurir: ${widget.user.nama}")); 
      
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
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: _buildAppBar(context, _pageTitles[_selectedIndex]),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFAB(context),
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white, // AppBar putih bersih
      elevation: 1.0, // Garis bayangan tipis
      automaticallyImplyLeading: false, // Hapus tombol kembali
      titleSpacing: 16.0,
      title: _selectedIndex == 0 
          ? Row(
              children: [
                Image.asset('assets/images/POSIND_2023.png', height: 35.0, errorBuilder: (c,e,s) => const Icon(Icons.all_inbox)),
                const SizedBox(width: 12),
                Text("Mailingroom", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            )
          : Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Colors.black87
              ),
            ),
      actions: [
        _buildNotificationIcon(context), 
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: InkWell(
            onTap: () => _onItemTapped(3), 
            borderRadius: BorderRadius.circular(20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: posBlue,
              child: Text(
                widget.user.nama.isNotEmpty ? widget.user.nama[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    bool hasNotification = true; 

    return IconButton(
      onPressed: () => _onItemTapped(2), 
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, color: Colors.black54, size: 28),
          if (hasNotification)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET BARU: FAB Kustom ---
  Widget? _buildFAB(BuildContext context) {
    // Sembunyikan jika peran adalah kurir
    if (widget.user.role == 'kurir') return null;
    // Sembunyikan jika BUKAN di tab Beranda
    if (_selectedIndex != 0) return null; 

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage()));
      },
      backgroundColor: posOrange,
      foregroundColor: Colors.white,
      tooltip: 'Kirim Surat',
      child: const Icon(Icons.add, size: 28),
    );
  }
  
  // --- WIDGET BARU: Bottom Nav Kustom ---
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // Background putih
        elevation: 0, // Hapus bayangan (sudah ada border)
        type: BottomNavigationBarType.fixed, // Selalu tampilkan label
        selectedItemColor: posBlue, // Warna tema
        unselectedItemColor: Colors.grey[600],
        // Atur font
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Surat'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}