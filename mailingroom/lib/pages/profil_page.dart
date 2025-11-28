import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart'; // Pastikan package ini ada, atau hapus widget FadeIn jika tidak ada
import '../auth/auth_service.dart';
import '../models/user.dart';

class ProfilPage extends StatelessWidget {
  final MyUser user;
  const ProfilPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    const Color posBlue = Color(0xFF00529C);
    const Color posOrange = Color(0xFFF37021);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Abu-abu sangat muda
      // Stack memungkinkan kita menumpuk Header di bawah, dan Konten di atasnya
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND (Gradient)
          Container(
            height: 220, // Tinggi header
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [posBlue, Color(0xFF0073E6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. KONTEN UTAMA (Scrollable)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 60), // Spasi untuk status bar
                
                // --- JUDUL HALAMAN (Di atas header) ---
                Text(
                  'Profil Saya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- KARTU UTAMA (FOTO & INFO DASAR) ---
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Kartu Putih di Belakang
                      Container(
                        margin: const EdgeInsets.only(top: 50), // Beri ruang untuk foto di atas
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // Padding atas besar untuk foto
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Nama
                            Text(
                              user.nama,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            // ID & Role
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: posBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${user.role.toUpperCase()} • ID: ${user.uid.substring(0, 8)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: posBlue,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 24),

                            // Info Detail (Grid/Column)
                            _buildDetailRow(Icons.email_outlined, 'Email', user.email),
                            const SizedBox(height: 16),
                            _buildDetailRow(Icons.phone_android_outlined, 'No. HP', user.phone ?? '-'),
                          ],
                        ),
                      ),
                      
                      // Foto Profil (Melayang di atas kartu)
                      Positioned(
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white, // Border putih tebal
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: posOrange,
                            child: Text(
                              user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- MENU PENGATURAN ---
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: Text(
                          "Pengaturan",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              context, 
                              title: 'Edit Profil', 
                              icon: Icons.edit_outlined, 
                              onTap: () {
                                // Navigator.push(...)
                              }
                            ),
                            const Divider(height: 1, indent: 60),
                            _buildSettingsTile(
                              context, 
                              title: 'Ubah Password', 
                              icon: Icons.lock_outline_rounded, 
                              onTap: () {}
                            ),
                            const Divider(height: 1, indent: 60),
                            _buildSettingsTile(
                              context, 
                              title: 'Bantuan & Dukungan', 
                              icon: Icons.help_outline_rounded, 
                              onTap: () {}
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- TOMBOL LOGOUT ---
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Keluar Akun",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Baris Info Detail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Helper: Menu Pengaturan (ListTile)
  Widget _buildSettingsTile(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  // Dialog Logout Konfirmasi
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Keluar?", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin keluar dari aplikasi?", style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              Provider.of<AuthService>(context, listen: false).signOut();
            },
            child: Text("Ya, Keluar", style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}