import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(prefs),
      child: const AuthenticatorApp(),
    ),
  );
}

class AuthenticatorApp extends StatelessWidget {
  const AuthenticatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: '身份验证器',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: provider.isOnboardingComplete ? '/' : '/onboarding',
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
