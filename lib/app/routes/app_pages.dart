import 'package:get/get.dart';

import '../modules/app_block_setting/bindings/app_block_setting_binding.dart';
import '../modules/app_block_setting/views/app_block_setting_view.dart';
import '../modules/article_detail/bindings/article_detail_binding.dart';
import '../modules/article_detail/views/article_detail_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/eye_monitoring/bindings/eye_monitoring_binding.dart';
import '../modules/eye_monitoring/views/eye_monitoring_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/insight/bindings/insight_binding.dart';
import '../modules/insight/views/insight_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/monitoring/bindings/monitoring_binding.dart';
import '../modules/monitoring/views/monitoring_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile_detail/bindings/profile_detail_binding.dart';
import '../modules/profile_detail/views/profile_detail_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // 🔥 FIX DI SINI
  static const INITIAL = '/splash';

  static final routes = [
    // Pastikan import LoginBinding dan LoginView
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.EYE_MONITORING,
      page: () => const EyeMonitoringView(),
      binding: EyeMonitoringBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.MONITORING,
      page: () => const MonitoringView(),
      binding: MonitoringBinding(),
    ),
    GetPage(
      name: _Paths.INSIGHT,
      page: () => const InsightView(),
      binding: InsightBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.APP_BLOCK_SETTING,
      page: () => const AppBlockSettingView(),
      binding: AppBlockSettingBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_DETAIL,
      page: () => const ProfileDetailView(),
      binding: ProfileDetailBinding(),
    ),
    GetPage(
      name: _Paths.ARTICLE_DETAIL,
      page: () => const ArticleDetailView(),
      binding: ArticleDetailBinding(),
    ),
  ];
}
