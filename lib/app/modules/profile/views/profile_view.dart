import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

// PALET WARNA LIGHT MODE
const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3142);
const Color textGrey = Color(0xFF9094A6);
const Color accentCyan = Color(0xFF00BFA5);
const Color warningYellow = Color(0xFFFFB300);
const Color dangerRed = Color(0xFFFF5252);

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight, // Pastikan background tab terang
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BAGIAN HEADER (INFO AKUN)
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showEditPhotoBottomSheet, 
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(radius: 50, backgroundColor: cardLight, child: Icon(Icons.person, size: 50, color: accentCyan)),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: accentCyan, shape: BoxShape.circle, border: Border.all(color: cardLight, width: 2)),
                          child: const Icon(Icons.camera_alt, size: 14, color: cardLight),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Saputra Aditama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                  const Text('saputra@driji.ai', style: TextStyle(color: textGrey, fontSize: 14)),
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
            const Text('Target Kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardLight, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.timer_outlined, 'Batas Screen Time', trailingText: '4 Jam', onTap: _showScreenTimeSheet),
                  const Divider(color: bgLight, height: 1, thickness: 1),
                  _buildProfileMenu(Icons.bedtime_outlined, 'Jam Tidur Ideal', trailingText: '22:00', onTap: () {
                    Get.snackbar('Fitur Segera Hadir', 'Sinkronisasi jam tidur sedang dikembangkan.', backgroundColor: textDark, colorText: Colors.white);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. BAGIAN PRIVASI & KEAMANAN
            const Text('Privasi & Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardLight, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.camera_alt_outlined, 'Izin Kamera AI', trailingText: 'On-Device', onTap: () => _showSecurityInfo('Arsitektur On-Device', 'Kamera hanya digunakan untuk analisis Frame by Frame secara lokal. Tidak ada gambar wajah yang dikirim atau disimpan di server.')),
                  const Divider(color: bgLight, height: 1, thickness: 1),
                  _buildProfileMenu(Icons.shield_outlined, 'Enkripsi Data', trailingText: 'Aktif', iconColor: warningYellow, onTap: () => _showSecurityInfo('End-to-End Encryption', 'Data kebiasaan dan metrik kesehatan Anda dienkripsi menggunakan standar AES-256 sebelum dikirim ke Web Service.')),
                  const Divider(color: bgLight, height: 1, thickness: 1),
                  _buildProfileMenu(Icons.cloud_sync_outlined, 'Sinkronisasi Cloud', trailingText: 'Terkoneksi', onTap: () {
                    Get.snackbar('Sinkronisasi', 'Data Big Data Anda telah disinkronkan dengan server.', backgroundColor: textDark, colorText: accentCyan, icon: const Icon(Icons.cloud_done, color: accentCyan));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. BAGIAN SISTEM & LOGOUT
            const Text('Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardLight, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.help_outline, 'Pusat Bantuan', showArrow: true, onTap: () {}),
                  const Divider(color: bgLight, height: 1, thickness: 1),
                  ListTile(
                    onTap: () {
                      Get.defaultDialog(
                        backgroundColor: cardLight,
                        title: 'Keluar Akun?',
                        titleStyle: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
                        middleText: 'Sesi pemantauan AI akan dihentikan sementara.',
                        middleTextStyle: const TextStyle(color: textGrey),
                        textCancel: 'Batal',
                        cancelTextColor: textGrey,
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
            const Center(child: Text('MIND DRIJI v1.0.0 (Capstone Beta)', style: TextStyle(color: textGrey, fontSize: 12))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, {String? trailingText, bool showArrow = false, Color iconColor = accentCyan, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: textDark, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: textGrey, fontSize: 12)),
          if (showArrow) const Icon(Icons.arrow_forward_ios, color: textGrey, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showEditPhotoBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: cardLight, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ubah Foto Profil', style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: accentCyan),
              title: const Text('Ambil dari Kamera', style: TextStyle(color: textDark)),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: accentCyan),
              title: const Text('Pilih dari Galeri', style: TextStyle(color: textDark)),
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
        decoration: const BoxDecoration(color: cardLight, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Atur Batas Screen Time', style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('AI akan memberi peringatan jika Anda melewati batas ini.', style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: textGrey),
                Expanded(
                  child: Slider(
                    value: 4, min: 1, max: 12, divisions: 11,
                    activeColor: accentCyan, inactiveColor: bgLight,
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
                style: ElevatedButton.styleFrom(backgroundColor: accentCyan, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
      backgroundColor: cardLight,
      title: title,
      titlePadding: const EdgeInsets.only(top: 24),
      titleStyle: const TextStyle(color: accentCyan, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.shield_rounded, color: warningYellow, size: 60),
            const SizedBox(height: 16),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: textGrey, height: 1.5)),
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