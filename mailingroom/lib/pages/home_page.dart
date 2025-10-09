// Path: lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'dashboard/pengirim_dashboard.dart';
import 'dashboard/kurir_dashboard.dart';
import 'dashboard/penerima_dashboard.dart';
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
      // appBar putih with icon left + avatar right similar to screenshot
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
                // banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFFE91E63)]),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('📬 Dashboard User', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Kelola surat masuk dan keluar', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text('${suratList.length} surat aktif', style: const TextStyle(color: Colors.white)),
                    )
                  ]),
                ),

                const SizedBox(height: 16),

                // search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
                  ]),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.black38),
                      hintText: 'Cari nomor surat atau perihal...',
                      border: InputBorder.none,
                      suffixIcon: IconButton(icon: const Icon(Icons.filter_alt), onPressed: () {}),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // quick actions grid
                const Text('Aksi Cepat', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _quickActionCard(Icons.add, 'Tambah Surat', 'Buat surat baru', Colors.blue),
                    _quickActionCard(Icons.inbox, 'Surat Masuk', 'Lihat kotak masuk', Colors.deepPurple),
                    _quickActionCard(Icons.send, 'Surat Keluar', 'Kirim surat', Colors.orange),
                    _quickActionCard(Icons.visibility, 'Lacak Surat', 'Cek status', Colors.green),
                  ],
                ),

                const SizedBox(height: 18),

                // statistics cards (2x2)
                const SectionHeader(title: 'Statistik'),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _statCard('Surat Masuk', '1', Icons.inbox, Colors.blue.shade50, Colors.blue),
                    _statCard('Surat Keluar', '1', Icons.send, Colors.orange.shade50, Colors.orange),
                    _statCard('Pending', '1', Icons.watch_later, Colors.yellow.shade50, Colors.amber),
                    _statCard('Selesai', '1', Icons.check_circle, Colors.green.shade50, Colors.green),
                  ],
                ),

                const SizedBox(height: 18),

                // Semua Surat
                const SectionHeader(title: '📂 Semua Surat', actionLabel: 'Lihat Semua', onAction: null),
                const SizedBox(height: 8),

                // list of surat (cards)
                Column(
                  children: suratList.map((s) => SuratCard(surat: s)).toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),

      // bottom nav
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // navigate to add page
          Navigator.pushNamed(context, '/add'); // if route exists
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _quickActionCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ]),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color bg, Color iconColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: iconColor)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ]),
      ]),
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
