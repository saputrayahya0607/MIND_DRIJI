import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
final supabase = Supabase.instance.client;

var userName = 'User'.obs;
var userEmail = ''.obs;

@override
void onInit() {
super.onInit();
loadUser();
}

void loadUser() {
final user = supabase.auth.currentUser;

if (user != null) {
  userEmail.value = user.email ?? '';

  final nama =
      user.userMetadata?['nama_lengkap'];

  if (nama != null &&
      nama.toString().isNotEmpty) {
    userName.value = nama;
  } else {
    userName.value =
        user.email?.split('@').first ??
        'User';
  }
}

}

Future<void> logout() async {
await supabase.auth.signOut();
}
}