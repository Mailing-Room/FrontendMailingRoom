// Path: lib/pages/profil_page.dart
import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // Helper widget untuk membuat setiap baris info
  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle, Widget? trailing, Color? iconColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
      trailing: trailing,
      onTap: onTap, // Aksi saat di-tap
    );
  }

  // Helper widget untuk header (lebih ringkas)
  Widget _buildHeader(Color blueColor) {
    return Column(
      children: [
        const SizedBox(height: 30), // Beri jarak lebih dari atas
        CircleAvatar(
          radius: 50, // Sedikit lebih besar
          backgroundColor: blueColor.withOpacity(0.1),
          child: Icon(Icons.person, size: 60, color: blueColor),
        ),
        const SizedBox(height: 16),
        const Text(
          'Kresnanda',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'User ID: 448311449',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Definisikan warna khas Pos Indonesia
    const Color posOrange = Color(0xFFF37021);
    const Color posBlue = Color(0xFF00529C);

    final userData = {
      'nama': 'Kresnanda Randysyah',
      'handphone': '0857-6368-1513',
      'referral': '847838',
      'email': 'kibo250504@gmail.com',
    };

    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar sedikit lebih gelap
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildHeader(posBlue),
          
          // --- KARTU INFORMASI AKUN ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                 Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Informasi Akun',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: posBlue),
                    ),
                  ),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.person_outline,
                  iconColor: posBlue,
                  title: 'Nama Lengkap',
                  subtitle: userData['nama']!,
                  trailing: IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 20, color: posOrange)),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.phone_android_outlined,
                  iconColor: posBlue,
                  title: 'Nomor Handphone',
                  subtitle: userData['handphone']!,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.card_giftcard_outlined,
                  iconColor: posBlue,
                  title: 'Kode Referral',
                  subtitle: userData['referral']!,
                  trailing: IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 20, color: posOrange)),
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.email_outlined,
                  iconColor: posBlue,
                  title: 'Email',
                  subtitle: userData['email']!,
                ),
                _buildInfoTile(
                  context,
                  icon: Icons.home_outlined,
                  iconColor: posBlue,
                  title: 'Alamat',
                  subtitle: 'Atur Alamat Anda',
                   trailing: Icon(Icons.chevron_right, color: posBlue),
                ),
                 _buildInfoTile(
                  context,
                  icon: Icons.lock_outline,
                  iconColor: posBlue,
                  title: 'PIN',
                  subtitle: '******',
                  trailing: Icon(Icons.chevron_right, color: posBlue),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- TOMBOL KELUAR (LOGOUT) ---
          TextButton.icon(
            onPressed: () {
              // TODO: Tambahkan logika untuk logout
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}