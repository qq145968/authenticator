import 'package:flutter/material.dart';
import 'presentation/onboarding/onboarding_page.dart';
import 'presentation/login/login_page.dart';
import 'presentation/main/main_page.dart';
import 'presentation/scan/scan_page.dart';
import 'presentation/manual_add/manual_add_page.dart';
import 'presentation/trash/trash_page.dart';
import 'presentation/profile/personal_info_page.dart';
import 'presentation/vip/vip_upgrade_page.dart';
import 'presentation/feedback/faq_page.dart';
import 'presentation/about/about_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/':
        return MaterialPageRoute(builder: (_) => const MainPage());
      case '/scan':
        return MaterialPageRoute(builder: (_) => const ScanPage());
      case '/manual_add':
        return MaterialPageRoute(builder: (_) => const ManualAddPage());
      case '/trash':
        return MaterialPageRoute(builder: (_) => const TrashPage());
      case '/personal_info':
        return MaterialPageRoute(builder: (_) => const PersonalInfoPage());
      case '/vip':
        return MaterialPageRoute(builder: (_) => const VipUpgradePage());
      case '/faq':
        return MaterialPageRoute(builder: (_) => const FaqPage());
      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('页面不存在')),
          ),
        );
    }
  }
}
