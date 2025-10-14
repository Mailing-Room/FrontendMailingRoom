// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

// Import dari project Anda (pastikan path-nya benar)
// Sesuaikan dengan struktur folder Anda jika berbeda
import '../models/surat.dart';
import '../services/database_service.dart';
import '../widgets/section_header.dart';
import '../widgets/surat_card.dart';
import 'add_edit_surat_pages.dart';
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'surat_rangkuman_page.dart';
import 'tracking_page.dart' hide Surat;


//====================================================================//
//                           KELAS BANTUAN                            //
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
//                        KONTEN TAB BERANDA                          //
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
        title: 'Tambah Surat', subtitle: 'Buat surat baru', icon: Icons.add_circle_outline,
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
                    childAspectRatio: 2.1, // Disesuaikan agar lebih ringkas
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
                childAspectRatio: 2.0, // Disesuaikan agar lebih ringkas
                children: [
                  _statCard('Surat Masuk', '1', posBlue),
                  _statCard('Surat Keluar', '1', posOrange),
                  _statCard('Pending', '1', Colors.amber.shade700),
                  _statCard('Selesai', '1', Colors.green.shade600),
                ],
              ),
              const SizedBox(height: 28),
              SectionHeader(
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

  // WIDGET KARTU AKSI CEPAT DENGAN UKURAN LEBIH KECIL
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

  // WIDGET KARTU STATISTIK DENGAN UKURAN LEBIH KECIL
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: indicatorColor,
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
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _initialSuratTabIndex = 0;

  static const Color posOrange = Color(0xFFF37021);
  static const Color posBlue = Color(0xFF00529C);

  void _onItemTapped(int index, {int subTabIndex = 0}) {
    setState(() {
      _selectedIndex = index;
      _initialSuratTabIndex = subTabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      BerandaContent(onNavigateToTab: _onItemTapped),
      SuratRangkumanPage(initialTabIndex: _initialSuratTabIndex),
      const NotifikasiPage(),
      const ProfilPage(),
    ];

    String appBarTitle;
    switch (_selectedIndex) {
      case 1:
        appBarTitle = 'Rangkuman Surat';
        break;
      case 2:
        appBarTitle = 'Notifikasi';
        break;
      case 3:
        appBarTitle = 'Profil Saya';
        break;
      default:
        appBarTitle = 'mailingroom';
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
                        // Ganti dengan SvgPicture.asset jika Anda menggunakan SVG
                        Image.asset(
                          'assets/images/POSIND_2023.svg.png', 
                          height: 35.0,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index),
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
      ),
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
}