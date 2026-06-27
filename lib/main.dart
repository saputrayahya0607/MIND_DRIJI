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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MIND DRIJI",
      debugShowCheckedModeBanner: false,

      // 🔥 START DARI SPLASH
      // initialRoute: Routes.SPLASH,
      initialRoute: Routes.LOGIN,

      getPages: AppPages.routes,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DE9B6),
        ),
      ),
    );
  }
}