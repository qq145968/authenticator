import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';
import 'presentation/widgets/privacy_agreement_dialog.dart';
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
        final initialRoute = provider.isOnboardingComplete
            ? '/'
            : '/onboarding';
        return MaterialApp(
          title: '身份验证器',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: initialRoute,
          onGenerateRoute: AppRouter.generateRoute,
          builder: (context, child) {
            // 使用 WidgetsBinding 在下一帧检查并弹出用户协议
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final navigator = Navigator.of(context, rootNavigator: true);
              // 检查 provider 状态并显示弹窗（通过全局 key 或 context 访问 provider）
              final p = Provider.of<AppProvider>(context, listen: false);
              if (!p.privacyAccepted) {
                _showPrivacyDialog(navigator.context, p);
              }
            });
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }

  /// 展示用户协议弹窗，防止重复弹出
  static bool _showingPrivacy = false;
  static void _showPrivacyDialog(BuildContext ctx, AppProvider provider) {
    if (_showingPrivacy) return;
    _showingPrivacy = true;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogCtx) => PrivacyAgreementDialog(
        onAccept: () async {
          await provider.acceptPrivacy();
          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
          _showingPrivacy = false;
        },
        onDecline: () {
          // 不同意则关闭应用（通过退出弹窗方式提示）
          _showingPrivacy = false;
        },
      ),
    ).then((_) {
      _showingPrivacy = false;
    });
  }
}
