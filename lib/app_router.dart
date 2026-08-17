import 'package:flutter/material.dart';
import 'presentation/onboarding/onboarding_page.dart';
import 'presentation/login/login_page.dart';
import 'presentation/main/main_page.dart';
import 'presentation/scan/scan_page.dart';
import 'presentation/manual_add/manual_add_page.dart';

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
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('页面不存在')),
          ),
        );
    }
  }
}
