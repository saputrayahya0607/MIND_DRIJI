import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // 🟡 1. Cek apakah user sudah pernah login sebelumnya
  final session = Supabase.instance.client.auth.currentSession;

  // 🟡 2. Tentukan rute tujuan otomatis
  // Jika session tidak kosong (ada user), langsung ke DASHBOARD. Jika kosong, ke LOGIN.
  final String ruteAwal = session != null ? Routes.DASHBOARD : Routes.LOGIN;

  // 🟡 3. Oper ruteAwal ini ke dalam MyApp
  runApp(MyApp(initialRoute: ruteAwal));
}

class MyApp extends StatelessWidget {
  // 🟡 4. Terima data initialRoute dari fungsi main di atas
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MIND DRIJI",
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(), // Binding bawaan kamu tetap terpasang aman

      // 🔥 SEKARANG OTOMATIS: Bisa Routes.HOME atau Routes.LOGIN tergantung session
      initialRoute: initialRoute,

      getPages: AppPages.routes,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DE9B6),
        ),
      ),
    );
  }
}