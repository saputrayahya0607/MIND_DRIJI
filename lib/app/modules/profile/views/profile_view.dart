import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/profile_detail/views/profile_detail_view.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart'; 
import '../../home/controllers/home_controller.dart'; // IMPORT HomeController UNTUK MENGAMBIL DATA GLOBAL

const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3142);
const Color textGrey = Color(0xFF9094A6);
const Color accentCyan = Color(0xFF00BFA5);
const Color dangerRed = Color(0xFFFF5252);

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileDetailView()), 
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 50, 
                          backgroundColor: cardLight, 
                          child: Icon(Icons.person, size: 50, color: accentCyan)
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: accentCyan, 
                            shape: BoxShape.circle, 
                            border: Border.all(color: cardLight, width: 2)
                          ),
                          child: const Icon(Icons.edit, size: 14, color: cardLight),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // ➡️ BUNGKUS NAMA DAN EMAIL DENGAN Obx()
                  Obx(() => Text(
                    controller.userName.value, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)
                  )),
                  Obx(() => Text(
                    controller.userEmail.value, 
                    style: const TextStyle(color: textGrey, fontSize: 14)
                  )),
                  
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentCyan.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all(color: accentCyan.withOpacity(0.5))
                    ),
                    child: const Text('Beta Tester', style: TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            const Text('Kontrol Aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardLight, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: _buildProfileMenu(
                Icons.app_blocking_outlined, 
                'Kelola Blokir Aplikasi', 
                showArrow: true, 
                onTap: () => Get.toNamed(Routes.APP_BLOCK_SETTING),
              ),
            ),
            const SizedBox(height: 24),

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
                        onConfirm: () {
                          // ➡️ TAMBAHAN: Bersihkan wadah data login saat logout
                          HomeController.dataUserLogin = null;
                          Get.offAllNamed(Routes.LOGIN);
                        }
                      );
                    },
                    leading: const Icon(Icons.logout, color: dangerRed),
                    title: const Text('Keluar Akun', style: TextStyle(color: dangerRed, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Center(child: Text('MIND DRIJI v1.0.0 (Capstone Beta)', style: TextStyle(color: textGrey, fontSize: 12))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, {bool showArrow = false, Color iconColor = accentCyan, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios, color: textGrey, size: 14) : null,
      onTap: onTap,
    );
  }
}