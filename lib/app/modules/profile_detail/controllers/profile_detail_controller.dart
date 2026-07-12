import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// =======================================================
// 1. 🔥 TAMBAHKAN IMPORT NOTIFICATION CONTROLLER DI SINI
// =======================================================
import 'package:mind_driji/app/modules/notification/controllers/notification_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class ProfileDetailController extends GetxController {
  final supabase = Supabase.instance.client;

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();

  var jenisKelamin = 'Laki-laki'.obs;
  var tanggalLahir = DateTime(2000, 1, 1).obs;
  var isLoading = false.obs;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && userId == null) {
        loadProfile();
      }
    });
  } 

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      print("🔍 currentUser: ${user?.id}, email: ${user?.email}");

      if (user == null) {
        print("❌ User NULL — auth session belum siap");
        return;
      }

      userId = user.id;

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      print("✅ Profile data: $profile");

      namaController.text = profile['nama_lengkap'] ?? '';
      emailController.text = profile['email'] ?? '';
      noHpController.text = profile['no_hp'] ?? '';

      if (profile['jenis_kelamin'] != null) {
        jenisKelamin.value = profile['jenis_kelamin'];
      }

      if (profile['tanggal_lahir'] != null) {
        tanggalLahir.value = DateTime.parse(profile['tanggal_lahir']);
      }
    } catch (e, stackTrace) {
      print("💥 ERROR loadProfile: $e");
      print(stackTrace);
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pilihTanggalLahir(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalLahir.value,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      tanggalLahir.value = picked;
    }
  }

  Future<void> simpanPerubahan() async {
  try {
    isLoading.value = true;

    if (userId == null) {
      throw Exception('User tidak ditemukan');
    }

    await supabase.from('profiles').update({
      'nama_lengkap': namaController.text.trim(),
      'no_hp': noHpController.text.trim(),
      'jenis_kelamin': jenisKelamin.value,
      'tanggal_lahir':
          tanggalLahir.value.toIso8601String().split('T').first,
    }).eq('id', userId!);

    final String namaBaru = namaController.text.trim();

    // 🌟 Update sumber data utama: HomeController.dataUserLogin
    if (HomeController.dataUserLogin != null) {
      HomeController.dataUserLogin!['nama_lengkap'] = namaBaru;
      HomeController.dataUserLogin!['no_hp'] = noHpController.text.trim();
      HomeController.dataUserLogin!['jenis_kelamin'] = jenisKelamin.value;
      HomeController.dataUserLogin!['tanggal_lahir'] =
          tanggalLahir.value.toIso8601String().split('T').first;
    }

    // 🌟 HomeController: update namaUser observable langsung
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().namaUser.value = namaBaru;
    }

    // 🌟 ProfileController: panggil ulang loadUser(), 
    // dia otomatis baca ulang dari HomeController.dataUserLogin yang barusan diupdate
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

    Get.snackbar('Berhasil', 'Profil berhasil diperbarui',
        backgroundColor: Colors.green, colorText: Colors.white);

    Get.back();
  } catch (e) {
    Get.snackbar('Gagal', e.toString(),
        backgroundColor: Colors.red, colorText: Colors.white);
  } finally {
    isLoading.value = false;
  }
}

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    super.onClose();
  }
}