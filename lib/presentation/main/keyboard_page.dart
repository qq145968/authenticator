import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';

class KeyboardPage extends StatefulWidget {
  const KeyboardPage({super.key});

  @override
  State<KeyboardPage> createState() => _KeyboardPageState();
}

class _KeyboardPageState extends State<KeyboardPage> {
  int _currentStep = 0;
  Timer? _stepTimer;
  final PageController _pageController = PageController();

  static const _stepDuration = Duration(seconds: 4);
  static const _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(_stepDuration, (_) {
      if (!mounted) return;
      final next = (_currentStep + 1) % _totalSteps;
      _goToStep(next);
    });
  }

  void _goToStep(int step) {
    if (!mounted) return;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  Future<void> _openInputMethodSettings() async {
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        const intent = AndroidIntent(
          action: 'android.settings.INPUT_METHOD_SETTINGS',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else {
        final uri = Uri.parse('App-Prefs:root=General');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (!mounted) return;
          _showSnackBar('请前往系统设置 → 键盘 → 输入法 中启用身份验证器键盘');
        }
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('请前往系统设置 → 输入法 中启用身份验证器键盘');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showEnableConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => _EnableConfirmDialog(
        onConfirm: () {
          Navigator.pop(context);
          _openInputMethodSettings();
        },
      ),
    );
  }

  void _showTryKeyboardDialog() {
    showDialog(
      context: context,
      builder: (context) => _TryKeyboardDialog(
        onGoEnable: () {
          Navigator.pop(context);
          _openInputMethodSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final accountCount = provider.accounts.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 20),
                  Text(
                    '启用动态验证码键盘',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '无需启动APP即可查看验证码！',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTutorialCarousel(accountCount, isDark),
                  const SizedBox(height: 20),
                  _buildStatusAndOptions(isDark),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _showEnableConfirmDialog,
                      child: const Text('立即启用', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '身份验证器',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text('Authenticator', style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.keyboard, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '在输入框中切换键盘，直接填入动态验证码',
              style: AppTextStyles.bodySecondary.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCarousel(int accountCount, bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentStep = index);
              _startAutoAdvance();
            },
            children: [
              _Step1Mockup(accountCount: accountCount, cardBg: cardBg, textColor: textColor, subTextColor: subTextColor),
              _Step2Mockup(cardBg: cardBg, textColor: textColor, subTextColor: subTextColor),
              _Step3Mockup(cardBg: cardBg, textColor: textColor, subTextColor: subTextColor),
              _Step4Mockup(cardBg: cardBg, textColor: textColor, subTextColor: subTextColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalSteps, (index) {
            final isActive = index == _currentStep;
            return GestureDetector(
              onTap: () => _goToStep(index),
              child: Container(
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : (isDark ? Colors.white24 : AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatusAndOptions(bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusTag('已开启同步', AppColors.wechatGreen),
                const SizedBox(width: 8),
                _buildStatusTag('本机可用', isDark ? Colors.white24 : AppColors.border),
              ],
            ),
          ),
          _buildOptionItem(
            icon: Icons.dialpad,
            iconColor: AppColors.primary,
            title: '当前验证码',
            subtitle: '查看本机所有动态验证码',
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
            onTap: () => _showSnackBar('请在输入法中切换到身份验证器键盘查看'),
          ),
          _buildOptionItem(
            icon: Icons.lock_outline,
            iconColor: Colors.orange,
            title: '锁定验证码',
            subtitle: '设置验证码访问密码保护',
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
            onTap: () => _showSnackBar('锁定验证码功能即将上线'),
          ),
          _buildOptionItem(
            icon: Icons.play_circle_outline,
            iconColor: AppColors.primary,
            title: '试用动态验证码键盘',
            subtitle: '体验键盘内快速填入验证码',
            textColor: textColor,
            subTextColor: subTextColor,
            isDark: isDark,
            showArrow: true,
            onTap: _showTryKeyboardDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: subTextColor)),
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.darkTextSecondary : AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _Step1Mockup extends StatelessWidget {
  final int accountCount;
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;

  const _Step1Mockup({
    required this.accountCount,
    required this.cardBg,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return _TutorialStep(
      stepTitle: '第一步：启用并同步',
      stepDesc: '在应用内同步令牌到本机键盘',
      cardBg: cardBg,
      textColor: textColor,
      subTextColor: subTextColor,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Text('身份验证器', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('启用动态令牌键盘', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.keyboard, color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Authenticator 动态令牌键盘（$accountCount个令牌 · 本机可用）',
                            style: TextStyle(fontSize: 10, color: subTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('立即启用'),
                        ),
                      ),
                      const Positioned(
                        right: 12,
                        top: -4,
                        child: _FingerTap(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2Mockup extends StatelessWidget {
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;

  const _Step2Mockup({required this.cardBg, required this.textColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return _TutorialStep(
      stepTitle: '第二步：启用动态口令键盘',
      stepDesc: '在系统设置中开启键盘和安全访问',
      cardBg: cardBg,
      textColor: textColor,
      subTextColor: subTextColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('管理输入法', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
                ],
              ),
            ),
            _MockInputMethodItem(name: '百度输入法定制版', enabled: false, textColor: textColor, subTextColor: subTextColor),
            const Divider(height: 1),
            _MockInputMethodItem(name: '搜狗输入法定制版', enabled: true, textColor: textColor, subTextColor: subTextColor),
            const Divider(height: 1),
            _MockInputMethodItem(name: '微信输入法', enabled: false, textColor: textColor, subTextColor: subTextColor),
            const Divider(height: 1),
            _MockInputMethodItem(
              name: 'Authenticator身份验证器',
              enabled: false,
              showFinger: true,
              textColor: textColor,
              subTextColor: subTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _Step3Mockup extends StatelessWidget {
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;

  const _Step3Mockup({required this.cardBg, required this.textColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return _TutorialStep(
      stepTitle: '第三步：切换输入法',
      stepDesc: '点击键盘右下角的小键盘图标',
      cardBg: cardBg,
      textColor: textColor,
      subTextColor: subTextColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Text('输入框中的验证码: 248913', style: TextStyle(fontSize: 10, color: subTextColor)),
            ),
            const SizedBox(height: 4),
            _buildMiniKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniKeyboard() {
    const rows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final key in row)
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(key, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text('空格', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 36,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.keyboard, size: 14, color: AppColors.primary),
                  ),
                ],
              ),
              const Positioned(
                right: 10,
                bottom: -6,
                child: _FingerTap(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step4Mockup extends StatelessWidget {
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;

  const _Step4Mockup({required this.cardBg, required this.textColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return _TutorialStep(
      stepTitle: '开始使用',
      stepDesc: '点击账户即可填入当前验证码',
      cardBg: cardBg,
      textColor: textColor,
      subTextColor: subTextColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  const Text('身份验证器', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('体验键盘', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  _MockAccountItem(initial: 'A', name: 'Authenticator', email: '身份验证器', code: '248 913', textColor: textColor, subTextColor: subTextColor),
                  const SizedBox(height: 4),
                  _MockAccountItem(initial: 'G', name: 'GitHub', email: 'chang***@gmail.com', code: '913', textColor: textColor, subTextColor: subTextColor),
                  const SizedBox(height: 4),
                  _MockAccountItem(initial: 'G', name: 'Google', email: '***@gmail.com', code: '562 104', textColor: textColor, subTextColor: subTextColor),
                  const SizedBox(height: 4),
                  _MockAccountItem(initial: 'S', name: 'Slack', email: '***@gmail.com', code: '935 280', textColor: textColor, subTextColor: subTextColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  final String stepTitle;
  final String stepDesc;
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;
  final Widget child;

  const _TutorialStep({
    required this.stepTitle,
    required this.stepDesc,
    required this.cardBg,
    required this.textColor,
    required this.subTextColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stepTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(stepDesc, style: TextStyle(fontSize: 12, color: subTextColor)),
            const SizedBox(height: 16),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    );
  }
}

class _MockInputMethodItem extends StatelessWidget {
  final String name;
  final bool enabled;
  final bool showFinger;
  final Color textColor;
  final Color subTextColor;

  const _MockInputMethodItem({
    required this.name,
    required this.enabled,
    this.showFinger = false,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(name, style: TextStyle(fontSize: 11, color: textColor))),
          Stack(
            children: [
              Container(
                width: 32,
                height: 18,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.wechatGreen : AppColors.border,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Align(
                  alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
              if (showFinger)
                const Positioned(right: -8, top: -8, child: _FingerTap(size: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockAccountItem extends StatelessWidget {
  final String initial;
  final String name;
  final String email;
  final String code;
  final Color textColor;
  final Color subTextColor;

  const _MockAccountItem({
    required this.initial,
    required this.name,
    required this.email,
    required this.code,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
                Text(email, style: TextStyle(fontSize: 8, color: subTextColor), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Text(code, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'monospace')),
              const SizedBox(width: 4),
              const Icon(Icons.copy, size: 12, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _FingerTap extends StatefulWidget {
  final double size;

  const _FingerTap({this.size = 24});

  @override
  State<_FingerTap> createState() => _FingerTapState();
}

class _FingerTapState extends State<_FingerTap> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Icon(
        Icons.touch_app,
        size: widget.size,
        color: Colors.orange,
        shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }
}

class _EnableConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _EnableConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              '启用动态验证码键盘',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '系统会提示输入法可能收集输入内容。App只展示并插入验证码，不读取或上传输入内容。',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.backgroundGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('取消', style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('确认', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TryKeyboardDialog extends StatelessWidget {
  final VoidCallback onGoEnable;

  const _TryKeyboardDialog({required this.onGoEnable});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.keyboard_hide, color: Colors.orange, size: 24),
            ),
            const SizedBox(height: 16),
            const Text(
              '请先开启系统键盘',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '请先在系统键盘设置中开启\nAuthenticator动态验证码，然后再试用。',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.backgroundGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('取消', style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onGoEnable,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('去开启', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
