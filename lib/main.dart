import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/login/views/login_view.dart';
import 'app/modules/login/bindings/login_binding.dart';

import 'app/modules/register/views/register_view.dart';
import 'app/modules/register/bindings/register_binding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MindGuard',
      debugShowCheckedModeBanner: false,

      // 🔥 START DARI LOGIN
      initialRoute: '/login',

      getPages: [
        // LOGIN
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),

        // REGISTER
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          binding: RegisterBinding(),
        ),
      ],
    );
  }
}