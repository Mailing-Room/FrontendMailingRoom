// Path: lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'add_edit_surat_pages.dart';
import 'notifikasi_page.dart';
import 'profil_page.dart';
import 'surat_rangkuman_page.dart';
import 'tracking_page.dart' hide Surat;
import '../widgets/section_header.dart';
import '../widgets/surat_card.dart';
import '../services/database_service.dart';
import '../models/surat.dart';

// KONTEN TAB BERANDA

class BerandaContent extends StatelessWidget {
  final Function(int, {int subTabIndex}) onNavigateToTab;
  const BerandaContent({super.key, required this.onNavigateToTab});

  static const Color posOrange = Color(0xFFF37021);
  static const Color posBlue = Color(0xFF00529C);

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();
    return StreamBuilder<List<Surat>>(
      stream: db.getSuratList(),
      builder: (context, snapshot) {
        final suratList = snapshot.data ?? [];
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aksi Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _quickActionCard(
                      Icons.add, 'Tambah Surat', 'Buat surat baru', posOrange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditSuratPage(),
                      ),
                    );
                  }),
                  _quickActionCard(Icons.travel_explore, 'Tracking Surat',
                      'Lacak posisi surat', Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackingPage(),
                      ),
                    );
                  }),
                  _quickActionCard(
                      Icons.inbox, 'Surat Masuk', 'Lihat kotak masuk', posBlue,
                      () {
                    onNavigateToTab(1, subTabIndex: 0);
                  }),
                  _quickActionCard(
                      Icons.send, 'Surat Keluar', 'Kirim surat', posOrange, () {
                    onNavigateToTab(1, subTabIndex: 1);
                  }),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Statistik'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.5,
                children: [
                  _statCard('Surat Masuk', '1', Icons.inbox, posBlue, posBlue),
                  _statCard(
                      'Surat Keluar', '1', Icons.send, posOrange, posOrange),
                  _statCard('Pending', '1', Icons.watch_later, Colors.amber,
                      Colors.amber),
                  _statCard('Selesai', '1', Icons.check_circle, Colors.green,
                      Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                  title: '📂 Surat Terbaru',
                  actionLabel: 'Lihat Semua',
                  onAction: null),
              const SizedBox(height: 8),
              Column(
                children: suratList.isEmpty
                    ? [const Center(child: Text('Belum ada surat.'))]
                    : suratList.map((s) => SuratCard(surat: s)).toList(),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  // Kartu aksi cepat
  Widget _quickActionCard(IconData icon, String title, String subtitle,
      Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  // Kartu statistik
  Widget _statCard(
      String title, String value, IconData icon, Color bg, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// HALAMAN UTAMA

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: _selectedIndex != 0,
        title: _selectedIndex == 0
            ? const Text(
                'mailingroom',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            : Text(appBarTitle),
        actions: [
          IconButton(
            onPressed: () {
              _onItemTapped(2);
            },
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              backgroundColor: posBlue,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: posBlue,
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
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
