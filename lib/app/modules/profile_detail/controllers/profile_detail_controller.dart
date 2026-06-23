import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;

      if (user == null) return;

      userId = user.id;

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      namaController.text =
          profile['nama_lengkap'] ?? '';

      emailController.text =
          profile['email'] ?? '';

      noHpController.text =
          profile['no_hp'] ?? '';

      if (profile['jenis_kelamin'] != null) {
        jenisKelamin.value =
            profile['jenis_kelamin'];
      }

      if (profile['tanggal_lahir'] != null) {
        tanggalLahir.value = DateTime.parse(
          profile['tanggal_lahir'],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pilihTanggalLahir(
    BuildContext context,
  ) async {
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
        throw Exception(
          'User tidak ditemukan',
        );
      }

      await supabase
          .from('profiles')
          .update({
            'nama_lengkap':
                namaController.text.trim(),
            'no_hp':
                noHpController.text.trim(),
            'jenis_kelamin':
                jenisKelamin.value,
            'tanggal_lahir':
                tanggalLahir.value
                    .toIso8601String()
                    .split('T')
                    .first,
          })
          .eq('id', userId!);

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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