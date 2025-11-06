// lib/pages/profil_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../models/user.dart'; 
// TODO: Buat halaman 'edit_profil_page.dart'
// import 'edit_profil_page.dart'; 

class ProfilPage extends StatelessWidget {
  // ✅ PERBAIKAN: Terima MyUser dari HomePage
  final MyUser user;
  const ProfilPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final Color posBlue = Theme.of(context).colorScheme.primary;
    final Color posOrange = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- HEADER PROFIL ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 20, right: 20),
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
                  radius: 45,
                  backgroundColor: posOrange,
                  child: Text(
                    // ✅ Tampilkan inisial nama dari backend
                    user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.nama, // ✅ Tampilkan nama dari backend
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'User ID: ${user.uid.substring(0, 8)}', // ✅ Tampilkan UID
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- KARTU INFORMASI AKUN ---
                  _buildSectionCard(
                    context: context,
                    title: 'Informasi Akun',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow('Nama Lengkap', user.nama),
                      _buildInfoRow('Email', user.email),
                      _buildInfoRow('Nomor Handphone', user.phone ?? '-'),
                      _buildInfoRow('Peran', user.role.toUpperCase()),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- KARTU PENGATURAN ---
                  _buildSectionCard(
                    context: context,
                    title: 'Pengaturan & Keamanan',
                    icon: Icons.security_outlined,
                    children: [
                      // ✅ Tombol Ubah Profil (Anda perlu membuat halamannya)
                      _buildNavRow(context, 'Ubah Profil', Icons.edit_outlined, () {
                        // Nanti:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilPage(user: user)));
                      }),
                      _buildNavRow(context, 'Ubah Password', Icons.lock_outline, () {}),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  // --- TOMBOL LOGOUT ---
                  ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<AuthService>(context, listen: false).signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar dari Akun'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat kartu
  Widget _buildSectionCard({required BuildContext context, required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...children,
        ],
      ),
    );
  }

  // Helper untuk baris info di profil
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk tombol navigasi
  Widget _buildNavRow(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[500], size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}