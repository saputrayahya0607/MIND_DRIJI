import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

const Color cardDark = Color(0xFF1D1E33);
const Color accentCyan = Color(0xFF1DE9B6);
const Color warningYellow = Color(0xFFFFD600);
const Color dangerRed = Color(0xFFFF5252);
const Color bgDark = Color(0xFF0A0E21);

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BAGIAN HEADER (INFO AKUN)
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showEditPhotoBottomSheet, // <-- Interaksi Ganti Foto
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(radius: 50, backgroundColor: cardDark, child: Icon(Icons.person, size: 50, color: accentCyan)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: accentCyan, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: bgDark),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Saputra Aditama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text('saputra@driji.ai', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: accentCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: accentCyan.withOpacity(0.5))),
                  child: const Text('Beta Tester', style: TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 2. BAGIAN TARGET KESEHATAN
          const Text('Target Kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildProfileMenu(Icons.timer_outlined, 'Batas Screen Time', trailingText: '4 Jam', onTap: _showScreenTimeSheet),
                const Divider(color: bgDark, height: 1, thickness: 1),
                _buildProfileMenu(Icons.bedtime_outlined, 'Jam Tidur Ideal', trailingText: '22:00', onTap: () {
                  Get.snackbar('Fitur Segera Hadir', 'Sinkronisasi jam tidur sedang dikembangkan.', backgroundColor: bgDark, colorText: Colors.white);
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. BAGIAN PRIVASI & KEAMANAN
          const Text('Privasi & Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildProfileMenu(Icons.camera_alt_outlined, 'Izin Kamera AI', trailingText: 'On-Device', onTap: () => _showSecurityInfo('Arsitektur On-Device', 'Kamera hanya digunakan untuk analisis Frame by Frame secara lokal. Tidak ada gambar wajah yang dikirim atau disimpan di server.')),
                const Divider(color: bgDark, height: 1, thickness: 1),
                _buildProfileMenu(Icons.shield_outlined, 'Enkripsi Data', trailingText: 'Aktif', iconColor: warningYellow, onTap: () => _showSecurityInfo('End-to-End Encryption', 'Data kebiasaan dan metrik kesehatan Anda dienkripsi menggunakan standar AES-256 sebelum dikirim ke Web Service.')),
                const Divider(color: bgDark, height: 1, thickness: 1),
                _buildProfileMenu(Icons.cloud_sync_outlined, 'Sinkronisasi Cloud', trailingText: 'Terkoneksi', onTap: () {
                  Get.snackbar('Sinkronisasi', 'Data Big Data Anda telah disinkronkan dengan server.', backgroundColor: bgDark, colorText: accentCyan, icon: const Icon(Icons.cloud_done, color: accentCyan));
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. BAGIAN SISTEM & LOGOUT
          const Text('Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', showArrow: true, onTap: () {}),
                const Divider(color: bgDark, height: 1, thickness: 1),
                ListTile(
                  onTap: () {
                    // Dialog Konfirmasi sebelum Logout
                    Get.defaultDialog(
                      backgroundColor: cardDark,
                      title: 'Keluar Akun?',
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      middleText: 'Sesi pemantauan AI akan dihentikan sementara.',
                      middleTextStyle: const TextStyle(color: Colors.grey),
                      textCancel: 'Batal',
                      cancelTextColor: accentCyan,
                      textConfirm: 'Keluar',
                      confirmTextColor: Colors.white,
                      buttonColor: dangerRed,
                      onConfirm: () => Get.offAllNamed(Routes.LOGIN),
                    );
                  },
                  leading: const Icon(Icons.logout, color: dangerRed),
                  title: const Text('Keluar Akun', style: TextStyle(color: dangerRed, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Center(child: Text('MIND DRIJI v1.0.0 (Capstone Beta)', style: TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // WIDGET HELPER MENU (Ditambah properti onTap)
  Widget _buildProfileMenu(IconData icon, String title, {String? trailingText, bool showArrow = false, Color iconColor = accentCyan, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (showArrow) const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  // ==========================================
  // FUNGSI-FUNGSI INTERAKSI GETX
  // ==========================================

  void _showEditPhotoBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ubah Foto Profil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: accentCyan),
              title: const Text('Ambil dari Kamera', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: accentCyan),
              title: const Text('Pilih dari Galeri', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _showScreenTimeSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: cardDark, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Atur Batas Screen Time', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('AI akan memberi peringatan jika Anda melewati batas ini.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            // Mockup Slider
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.grey),
                Expanded(
                  child: Slider(
                    value: 4, min: 1, max: 12, divisions: 11,
                    activeColor: accentCyan, inactiveColor: bgDark,
                    label: '4 Jam',
                    onChanged: (val) {},
                  ),
                ),
                const Text('4 Jam', style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentCyan, foregroundColor: bgDark, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () => Get.back(),
                child: const Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSecurityInfo(String title, String desc) {
    Get.defaultDialog(
      backgroundColor: bgDark,
      title: title,
      titlePadding: const EdgeInsets.only(top: 24),
      titleStyle: const TextStyle(color: accentCyan, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.shield_rounded, color: warningYellow, size: 60),
            const SizedBox(height: 16),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.5)),
          ],
        ),
      ),
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Tutup', style: TextStyle(color: accentCyan)),
      ),
    );
  }
}