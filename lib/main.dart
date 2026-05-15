// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'app/modules/login/views/login_view.dart';
// import 'app/modules/login/bindings/login_binding.dart';

// import 'app/modules/register/views/register_view.dart';
// import 'app/modules/register/bindings/register_binding.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'MindGuard',
//       debugShowCheckedModeBanner: false,

//       // 🔥 START DARI LOGIN
//       initialRoute: '/login',

//       getPages: [
//         // LOGIN
//         GetPage(
//           name: '/login',
//           page: () => const LoginView(),
//           binding: LoginBinding(),
//         ),

//         // REGISTER
//         GetPage(
//           name: '/register',
//           page: () => const RegisterView(),
//           binding: RegisterBinding(),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Pastikan path import ini sesuai dengan struktur folder Anda
import 'app/routes/app_pages.dart'; 


void main() {
  // Memastikan binding Flutter sudah siap sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MIND DRIJI",
      debugShowCheckedModeBanner: false,
      // Mengatur rute awal saat aplikasi pertama kali dibuka.
      // Ubah Routes.LOGIN menjadi Routes.SPLASH jika Anda sudah membuat halaman Splash.
      initialRoute: Routes.LOGIN, 
      // Memanggil daftar semua halaman yang sudah didaftarkan di app_pages.dart
      getPages: AppPages.routes,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // bgDark
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DE9B6), // accentCyan
        ),
        fontFamily: 'Roboto', 
      ),
    );
  }
}