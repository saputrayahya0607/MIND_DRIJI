import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  // Controller
  final namaController = TextEditingController(text: 'Saputra Aditama');
  final noHpController = TextEditingController(text: '081234567890');
  final passwordController = TextEditingController(); // Controller Password
  
  // State variables
  DateTime tanggalLahir = DateTime(2004, 5, 16);
  String jenisKelamin = 'Laki-laki';
  String email = 'saputra@driji.ai'; 
  bool isPasswordHidden = true; // Untuk toggle mata password

  void _pilihTanggalLahir() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggalLahir,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != tanggalLahir) {
      setState(() {
        tanggalLahir = picked;
      });
    }
  }

  // Bottom sheet untuk ganti foto pindah ke sini
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

  void _simpanPerubahan() {
    // Validasi Password Kosong
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Aksi Ditolak', 
        'Harap masukkan password Anda untuk menyimpan perubahan.',
        backgroundColor: dangerRed,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16)
      );
      return;
    }

    // Mengemas data termasuk konfirmasi password
    Map<String, dynamic> profileData = {
      'nama_lengkap': namaController.text,
      'tanggal_lahir': tanggalLahir.toIso8601String(), 
      'jenis_kelamin': jenisKelamin,
      'email': email,
      'no_hp': noHpController.text,
      'password_konfirmasi': passwordController.text,
    };

    print("DATA PROFILE UPDATE: $profileData");

    Get.back(); // Kembali ke halaman profil
    Get.snackbar(
      'Berhasil', 
      'Profil Anda berhasil diperbarui',
      backgroundColor: textDark,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16)
    );
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
            // FOTO PROFIL BISA DIUBAH DI SINI
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
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white), // Ikon kamera
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // FORM EDIT DATA
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
                          Text("${tanggalLahir.day}/${tanggalLahir.month}/${tanggalLahir.year}", style: const TextStyle(color: textDark)),
                          const Icon(Icons.calendar_month_outlined, color: accentCyan),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // KONFIRMASI PASSWORD & LUPA PASSWORD
                  const Divider(color: bgLight, thickness: 2),
                  const SizedBox(height: 16),
                  
                  _buildLabel('Konfirmasi Password'),
                  TextField(
                    controller: passwordController,
                    obscureText: isPasswordHidden,
                    style: const TextStyle(color: textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Masukkan password saat ini',
                      hintStyle: const TextStyle(color: textGrey, fontSize: 12),
                      prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordHidden ? Icons.visibility_off : Icons.visibility, color: textGrey),
                        onPressed: () {
                          setState(() { isPasswordHidden = !isPasswordHidden; });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: textGrey.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: accentCyan)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  
                  // Tombol Lupa Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Logika jika lupa password
                        Get.snackbar('Bantuan', 'Link reset password telah dikirim ke email Anda.', backgroundColor: bgLight, colorText: textDark);
                      },
                      child: const Text('Lupa password?', style: TextStyle(color: accentCyan, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentCyan, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _simpanPerubahan,
                child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
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