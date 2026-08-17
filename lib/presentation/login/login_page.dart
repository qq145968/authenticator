import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../main/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreed = false;

  final List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.cloud_sync,
      title: '云端同步',
      description: '换手机不再丢失验证码账户',
    ),
    _FeatureItem(
      icon: Icons.folder_outlined,
      title: '分组管理',
      description: '按工作、学习等场景整理验证码账户',
    ),
    _FeatureItem(
      icon: Icons.keyboard,
      title: '验证码键盘',
      description: '在输入框中快速填入动态验证码',
    ),
  ];

  Future<void> _login() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先阅读并同意用户协议和隐私政策'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await context.read<AppProvider>().login('用户${DateTime.now().millisecondsSinceEpoch % 10000}');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  void _showAgreement(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: AppTextStyles.heading2),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    '欢迎使用身份验证器应用。本协议将向您说明我们如何收集、使用和保护您的个人信息。\n\n'
                    '1. 信息收集\n我们仅收集您主动添加的2FA验证码账户信息（发行方、标签、密钥），这些信息存储在您的设备本地或经过端到端加密后同步至云端。\n\n'
                    '2. 信息使用\n收集的信息仅用于生成动态验证码和跨设备同步，不会用于其他目的。\n\n'
                    '3. 信息安全\n我们采用AES-256加密和TOTP行业标准保护您的数据安全。所有验证码均在本地生成，不上传至服务器。\n\n'
                    '4. 用户权利\n您有权随时删除账户信息、取消云端同步、注销账户。\n\n'
                    '5. 协议更新\n本协议可能不时更新，更新后将在应用内通知您。',
                    style: AppTextStyles.bodySecondary.copyWith(height: 1.8),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '身份验证器',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '登录后安全同步您的验证码账户',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.shield, color: AppColors.primary, size: 48),
                          Positioned(
                            bottom: 16,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLighter,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(feature.icon, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(feature.title, style: AppTextStyles.heading3),
                                const SizedBox(height: 2),
                                Text(feature.description, style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.wechatGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wechat, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              '微信一键登录',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _login,
                      child: Text(
                        '其他登录方式',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _agreed ? AppColors.primary : AppColors.border,
                                width: 2,
                              ),
                              color: _agreed ? AppColors.primary : Colors.transparent,
                            ),
                            child: _agreed
                                ? const Icon(Icons.check, color: Colors.white, size: 14)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            children: [
                              const Text(
                                '已阅读并同意',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              GestureDetector(
                                onTap: () => _showAgreement('用户协议'),
                                child: const Text(
                                  '《用户协议》',
                                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                                ),
                              ),
                              const Text(
                                '和',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              GestureDetector(
                                onTap: () => _showAgreement('隐私政策'),
                                child: const Text(
                                  '《隐私政策》',
                                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
