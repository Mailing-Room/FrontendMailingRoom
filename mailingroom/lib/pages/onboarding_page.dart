// lib/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Pastikan Anda sudah 'flutter pub add animate_do'

class OnboardingPage extends StatefulWidget {
  final VoidCallback onOnboardingComplete;
  
  const OnboardingPage({super.key, required this.onOnboardingComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Daftar halaman onboarding
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.mail_lock_outlined,
      'title': 'Selamat Datang di Mailing Room',
      'subtitle': 'Solusi digital untuk mengelola, melacak, dan mengirim surat internal Anda dengan lebih efisien.',
    },
    {
      'icon': Icons.qr_code_scanner_rounded,
      'title': 'Pelacakan Real-Time',
      'subtitle': 'Ketahui status dan lokasi surat Anda, dari pengirim hingga penerima, langsung dari aplikasi.',
    },
    {
      'icon': Icons.people_alt_outlined,
      'title': 'Satu Aplikasi, Banyak Peran',
      'subtitle': 'Baik Anda Admin, Kurir, atau Pengirim, semua fitur yang Anda butuhkan ada dalam genggaman.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color posBlue = Theme.of(context).colorScheme.primary;
    final Color posOrange = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            // --- PERBAIKAN: Menambahkan Logo Kembali ---
            Padding(
              // Beri padding agar logo tidak menempel
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Logo kiri, Tombol kanan
                children: [
                  // Logo Pos (Asumsi dari file lain)
                  Image.asset(
                    'assets/images/logo_pos.png', 
                    height: 35.0, 
                    errorBuilder: (c, e, s) => const Icon(Icons.all_inbox, size: 35.0),
                  ),
                  
                  // Tombol Lewati
                  TextButton(
                    onPressed: widget.onOnboardingComplete,
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            // --- AKHIR PERBAIKAN ---

            // --- Konten Halaman (Responsif) ---
            Expanded(
              flex: 5, // Beri lebih banyak ruang untuk konten
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  // Tampilkan animasi hanya saat halaman aktif
                  return _OnboardingScreen(
                    key: ValueKey(index), // Kunci unik untuk animasi
                    iconData: item['icon'],
                    title: item['title'],
                    subtitle: item['subtitle'],
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // --- Navigasi Bawah (Responsif & Anti-Overflow) ---
            Expanded(
              flex: 1, // Beri ruang lebih sedikit untuk navigasi
              child: Padding(
                // Mengurangi padding dari 24.0 menjadi 16.0
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // Gunakan MainAxisSize.min agar Column tidak "rakus" tempat
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indikator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildDot(index, context, posBlue),
                      ),
                    ),
                    // Mengurangi SizedBox dari 24 menjadi 16
                    const SizedBox(height: 16), 
                    
                    // Tombol Lanjut/Mulai
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          widget.onOnboardingComplete();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: posOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat dot
  Widget _buildDot(int index, BuildContext context, Color activeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 30 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? activeColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// Widget helper untuk satu layar onboarding
class _OnboardingScreen extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final bool isActive;

  const _OnboardingScreen({
    super.key,
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  // Widget helper untuk ikon yang lebih menarik
  Widget _buildIconDisplay(BuildContext context, Color color) {
    return Container(
      width: 250, // Lingkaran dekoratif besar
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05), // Warna background tipis
      ),
      child: Center(
        child: Container(
          width: 180, // Lingkaran dalam
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1), // Warna background lebih pekat
          ),
          child: Center(
            child: Icon(
              iconData,
              size: 100, // Ukuran ikon
              color: color.withOpacity(0.9), // Warna ikon
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Membungkus dengan SingleChildScrollView (FIX OVERFLOW)
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar/Ikon
            // Hanya animasikan jika halaman aktif
            isActive
                ? FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    // Menggunakan helper ikon baru
                    child: _buildIconDisplay(context, Theme.of(context).colorScheme.primary),
                  )
                : _buildIconDisplay(context, Theme.of(context).colorScheme.primary),
            
            const SizedBox(height: 48),

            // Teks Judul
            isActive
                ? FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    title,
                    textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ),
            
            const SizedBox(height: 16),

            // Teks Subjudul
            isActive
                ? FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
            const SizedBox(height: 24), // Beri padding bawah jika di-scroll
          ],
        ),
      ),
    );
  }
}