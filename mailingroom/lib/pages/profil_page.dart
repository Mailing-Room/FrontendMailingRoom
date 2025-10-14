// lib/pages/profil_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // Warna khas Pos Indonesia
  static const Color posBlue = Color(0xFF00529C);
  static const Color posOrange = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    // Data pengguna (contoh)
    final userData = {
      'nama': 'Kresnanda Randyansyah',
      'userID': '448311449',
      'handphone': '0857-6368-1513',
      'referral': '847838',
      'email': 'kibo250504@gmail.com',
    };

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Menggunakan AppBar untuk judul halaman
      appBar: AppBar(
        title: Text('Profil Saya', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: posBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Body sekarang bisa di-scroll
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PROFIL ---
            _buildProfileHeader(userData),

            // --- KONTEN UTAMA ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- KARTU INFORMASI AKUN ---
                  _buildInfoCard(
                    title: 'Informasi Akun',
                    icon: Icons.person_pin_circle_outlined,
                    children: [
                      _buildInfoTile(icon: Icons.person_outline, title: 'Nama Lengkap', subtitle: userData['nama']!),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildInfoTile(icon: Icons.phone_android_outlined, title: 'Nomor Handphone', subtitle: userData['handphone']!),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildInfoTile(icon: Icons.email_outlined, title: 'Email', subtitle: userData['email']!),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- KARTU PENGATURAN & KEAMANAN ---
                  _buildInfoCard(
                    title: 'Pengaturan & Keamanan',
                    icon: Icons.security_outlined,
                    children: [
                      _buildInfoTile(
                        icon: Icons.home_outlined,
                        title: 'Alamat',
                        subtitle: 'Atur Alamat Pengiriman',
                        trailing: Icon(Icons.chevron_right, color: posBlue.withOpacity(0.7)),
                        onTap: () { /* TODO: Logika ke halaman alamat */ },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildInfoTile(
                        icon: Icons.lock_outline,
                        title: 'Ubah Password & PIN',
                        subtitle: '******',
                        trailing: Icon(Icons.chevron_right, color: posBlue.withOpacity(0.7)),
                        onTap: () { /* TODO: Logika ke halaman ubah password */ },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- TOMBOL KELUAR (LOGOUT) ---
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Tambahkan logika untuk logout
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text('Keluar dari Akun', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat header profil
  Widget _buildProfileHeader(Map<String, String> userData) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: posBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: posOrange.withOpacity(0.1),
              child: Icon(Icons.person, size: 60, color: posOrange),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userData['nama']!,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'User ID: ${userData['userID']}',
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat kartu informasi
  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: posBlue, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: posBlue),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // Widget helper untuk membuat setiap baris info
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: posBlue.withOpacity(0.7), size: 24),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: trailing,
    );
  }
}