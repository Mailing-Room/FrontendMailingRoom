// Path: lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'add_edit_surat_pages.dart';
import '../widgets/section_header.dart';
import '../widgets/surat_card.dart';
import '../services/database_service.dart';
import '../models/surat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentPurpleA = Color(0xFF8E24AA);

  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: accentPurpleA, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.description, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('mailingroom', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Kelola surat masuk dan keluar', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(backgroundColor: accentPurpleA, child: const Icon(Icons.person, color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<List<Surat>>(
        stream: _db.getSuratList(),
        builder: (context, snapshot) {
          final suratList = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aksi Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8, // Disesuaikan
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _quickActionCard(
                      Icons.add, 'Tambah Surat', 'Buat surat baru', Colors.blue, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage()));
                      }
                    ),
                    _quickActionCard(
                      Icons.travel_explore, 'Tracking Surat', 'Lacak posisi surat', Colors.green, () {}
                    ),
                    _quickActionCard(
                      Icons.inbox, 'Surat Masuk', 'Lihat kotak masuk', Colors.deepPurple, () {}
                    ),
                    _quickActionCard(
                      Icons.send, 'Surat Keluar', 'Kirim surat', Colors.orange, () {}
                    ),
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
                  childAspectRatio: 2.5, // Disesuaikan
                  children: [
                    _statCard('Surat Masuk', '1', Icons.inbox, Colors.blue, Colors.blue),
                    _statCard('Surat Keluar', '1', Icons.send, Colors.orange, Colors.orange),
                    _statCard('Pending', '1', Icons.watch_later, Colors.amber, Colors.amber),
                    _statCard('Selesai', '1', Icons.check_circle, Colors.green, Colors.green),
                  ],
                ),

                const SizedBox(height: 24),

                const SectionHeader(title: '📂 Surat Terbaru', actionLabel: 'Lihat Semua', onAction: null),
                const SizedBox(height: 8),
                Column(
                  children: suratList.map((s) => SuratCard(surat: s)).toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSuratPage()));
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ✅ _quickActionCard DENGAN FITTEDBOX
  Widget _quickActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ]),
        ),
      ),
    );
  }

  // ✅ _statCard DENGAN FITTEDBOX
  Widget _statCard(String title, String value, IconData icon, Color bg, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: iconColor),
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8E24AA),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Surat'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}