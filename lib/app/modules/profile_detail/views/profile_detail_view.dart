import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:mind_driji/app/modules/notification/controllers/notification_controller.dart';

const Color bgLight = Color(0xFFF5F7FA);
const Color cardLight = Color(0xFFFFFFFF);
const Color textDark = Color(0xFF2D3142);
const Color textGrey = Color(0xFF9094A6);
const Color accentCyan = Color(0xFF00BFA5);
const Color dangerRed = Color(0xFFFF5252);

class ProfileDetailView extends StatefulWidget {
  const ProfileDetailView({Key? key}) : super(key: key);

  @override
  State<ProfileDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ProfileDetailView> {
  // Controller Form
  late TextEditingController namaController;
  late TextEditingController noHpController;
  // final passwordController = TextEditingController(); 
  
  // State variables
  DateTime tanggalLahir = DateTime(2004, 5, 16); // Nilai default jika data null
  String jenisKelamin = 'Laki-laki'; // Nilai default jika data null
  String email = 'email@domain.com'; 
  // bool isPasswordHidden = true; 
  bool isLoading = false; 

  @override
  void initState() {
    super.initState();
    
    // 1. Tentukan nilai default/fallback jika data di DB memang masih kosong (null)
    String initialName = '';
    String initialHp = ''; // Kosongkan saja agar user bisa isi sendiri nanti
    jenisKelamin = 'Laki-laki';
    tanggalLahir = DateTime(2000, 1, 1); // Default awal tahun 2000

    if (HomeController.dataUserLogin != null) {
      final user = HomeController.dataUserLogin!;

      // Sinkronisasi Nama Lengkap & Email
      if (user['nama_lengkap'] != null && user['nama_lengkap'].toString().isNotEmpty) {
        initialName = user['nama_lengkap'].toString();
      }
      if (user['email'] != null) {
        email = user['email'].toString();
      }
      
      // ➡️ 2. AMBIL NO HP JIKA ADA DI DATABASE, JIKA NULL TETAP AMAN
      if (user['no_hp'] != null && user['no_hp'].toString().isNotEmpty) {
        initialHp = user['no_hp'].toString();
      }
      
      // ➡️ 3. AMBIL JENIS KELAMIN JIKA ADA DI DATABASE
      if (user['jenis_kelamin'] != null && user['jenis_kelamin'].toString().isNotEmpty) {
        String jkDb = user['jenis_kelamin'].toString();
        if (jkDb == 'Laki-laki' || jkDb == 'Perempuan') {
          jenisKelamin = jkDb;
        }
      }
      
      // ➡️ 4. AMBIL TANGGAL LAHIR JIKA ADA DI DATABASE
      if (user['tanggal_lahir'] != null && user['tanggal_lahir'].toString().isNotEmpty) {
        try {
          tanggalLahir = DateTime.parse(user['tanggal_lahir'].toString());
        } catch (e) {
          print("Format tanggal dari DB tidak sesuai standar YYYY-MM-DD: $e");
        }
      }
    }

    // Masukkan data (baik dari DB atau nilai default aman) ke controller form
    namaController = TextEditingController(text: initialName);
    noHpController = TextEditingController(text: initialHp);
  }

  @override
  void dispose() {
    namaController.dispose();
    noHpController.dispose();
    // passwordController.dispose();
    super.dispose();
  }

  void _pilihTanggalLahir() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggalLahir,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != tanggalLahir) {
      // ➡️ Menggunakan setState agar teks tanggal langsung berubah di layar
      setState(() {
        tanggalLahir = picked;
      });
    }
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
            ListTile(leading: const Icon(Icons.camera_alt, color: accentCyan), title: const Text('Ambil dari Kamera', style: TextStyle(color: textDark)), onTap: () => Get.back()),
            ListTile(leading: const Icon(Icons.photo_library, color: accentCyan), title: const Text('Pilih dari Galeri', style: TextStyle(color: textDark)), onTap: () => Get.back()),
          ],
        ),
      ),
    );
  }

  Future<void> _simpanPerubahan() async {
  setState(() {
    isLoading = true;
  });

  try {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('User tidak ditemukan');
    }

    await Supabase.instance.client.from('profiles').update({
      'nama_lengkap': namaController.text.trim(),
      'no_hp': noHpController.text.trim(),
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir.toIso8601String().split('T').first,
    }).eq('id', user.id);

    final String namaBaru = namaController.text.trim();

    if (HomeController.dataUserLogin != null) {
      HomeController.dataUserLogin!['nama_lengkap'] = namaBaru;
      HomeController.dataUserLogin!['no_hp'] = noHpController.text.trim();
      HomeController.dataUserLogin!['jenis_kelamin'] = jenisKelamin;
      HomeController.dataUserLogin!['tanggal_lahir'] =
          tanggalLahir.toIso8601String().split('T').first;
    }

    // 🌟 TAMBAHKAN INI — sinkronkan ke controller lain yang aktif
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().namaUser.value = namaBaru;
    }

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadUser();
    }

    try {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().addLog(
          'Profil Diperbarui 👤',
          'Informasi detail profil Anda berhasil diperbarui.',
          'profile',
        );
      }
    } catch (e) {
      print("⚠️ Gagal nge-log notifikasi: $e");
    }

    Get.back();

    Get.snackbar(
      'Berhasil',
      'Profil berhasil diperbarui',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      'Error',
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: textDark), onPressed: () => Get.back()),
        title: const Text('Edit Profil', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _showEditPhotoBottomSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(radius: 50, backgroundColor: cardLight, child: Icon(Icons.person, size: 50, color: accentCyan)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: accentCyan, shape: BoxShape.circle, border: Border.all(color: bgLight, width: 3)),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white), 
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardLight, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nama Lengkap'),
                  _buildTextField(namaController, Icons.person_outline),
                  const SizedBox(height: 20),

                  _buildLabel('Email'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(15)),
                    child: Text(email, style: const TextStyle(color: textGrey)),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Nomor WhatsApp / HP'),
                  _buildTextField(noHpController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),

                  _buildLabel('Jenis Kelamin'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: textGrey.withOpacity(0.3))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: jenisKelamin,
                        isExpanded: true,
                        style: const TextStyle(color: textDark, fontSize: 14),
                        onChanged: (String? newValue) {
                          // ➡️ setState dipastikan ada di sini agar visual Dropdown langsung berganti pilihan
                          setState(() { jenisKelamin = newValue!; });
                        },
                        items: <String>['Laki-laki', 'Perempuan'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Tanggal Lahir'),
                  InkWell(
                    onTap: _pilihTanggalLahir,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: textGrey.withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tampilan teks tanggal mengikuti state tanggalLahir terbaru
                          Text("${tanggalLahir.day}/${tanggalLahir.month}/${tanggalLahir.year}", style: const TextStyle(color: textDark)),
                          const Icon(Icons.calendar_month_outlined, color: accentCyan),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Divider(color: bgLight, thickness: 2),
                  const SizedBox(height: 16),
                  
            //       _buildLabel('Konfirmasi Password'),
            //       TextField(
            //         controller: passwordController,
            //         obscureText: isPasswordHidden,
            //         style: const TextStyle(color: textDark, fontSize: 14),
            //         decoration: InputDecoration(
            //           hintText: 'Masukkan password saat ini',
            //           hintStyle: const TextStyle(color: textGrey, fontSize: 12),
            //           prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
            //           suffixIcon: IconButton(
            //             icon: Icon(isPasswordHidden ? Icons.visibility_off : Icons.visibility, color: textGrey),
            //             onPressed: () {
            //               setState(() { isPasswordHidden = !isPasswordHidden; });
            //             },
            //           ),
            //           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: textGrey.withOpacity(0.3))),
            //           focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentCyan)),
            //           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentCyan, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: isLoading ? null : _simpanPerubahan,
                child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ],),
    ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: textDark, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: textGrey),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: textGrey.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentCyan)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}