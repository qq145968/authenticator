import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _darkMode = provider.isDarkMode;
  }

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能即将上线'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？退出后云端同步将暂停。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await this.context.read<AppProvider>().logout();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('退出', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isLoggedIn = provider.isLoggedIn;
    final user = provider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVipCard(),
            const SizedBox(height: 16),
            _buildUserCard(isLoggedIn, user),
            const SizedBox(height: 16),
            _buildMenuList(context, provider),
            const SizedBox(height: 16),
            if (isLoggedIn)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _showLogoutDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.vipGradientStart, AppColors.vipGradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.starYellow, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    '升级VIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '开启云端同步 · 无限账户 · 端到端加密保护',
                style: TextStyle(color: Colors.white.withOpacity( 0.8), fontSize: 13),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _showComingSoon('VIP'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '立即开通',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.star, color: AppColors.starYellow.withOpacity( 0.6), size: 32),
          ),
          Positioned(
            top: 20,
            right: 24,
            child: Icon(Icons.star, color: Colors.white.withOpacity( 0.3), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(bool isLoggedIn, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLighter,
            child: isLoggedIn
                ? Text(
                    (user?.username ?? '?')[0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.person, color: AppColors.textSecondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? (user?.username ?? '用户') : '未登录',
                  style: AppTextStyles.heading3.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn
                      ? (user?.plan ?? '免费版')
                      : '登录后查看已添加的密钥',
                  style: TextStyle(
                    fontSize: 13,
                    color: isLoggedIn
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isLoggedIn)
            ElevatedButton(
              onPressed: _navigateToLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('前往登录', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final iconColor = AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.dark_mode_outlined,
            iconColor: iconColor,
            title: '深色模式',
            textColor: textColor,
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                provider.toggleDarkMode();
              },
            ),
          ),
          const Divider(indent: 16),
          _buildMenuItem(
            icon: Icons.delete_outline,
            iconColor: iconColor,
            title: '回收站',
            textColor: textColor,
            subtitle: '查看已删除的验证码账户',
            onTap: () => _showComingSoon('回收站'),
          ),
          const Divider(indent: 16),
          _buildMenuItem(
            icon: Icons.help_outline,
            iconColor: iconColor,
            title: '常见问题',
            textColor: textColor,
            onTap: () => _showComingSoon('常见问题'),
          ),
          const Divider(indent: 16),
          _buildMenuItem(
            icon: Icons.feedback_outlined,
            iconColor: iconColor,
            title: '问题反馈',
            textColor: textColor,
            onTap: () => _showComingSoon('问题反馈'),
          ),
          const Divider(indent: 16),
          _buildMenuItem(
            icon: Icons.receipt_outlined,
            iconColor: iconColor,
            title: '开具发票',
            textColor: textColor,
            onTap: () => _showComingSoon('开具发票'),
          ),
          const Divider(indent: 16),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: iconColor,
            title: '关于我们',
            textColor: textColor,
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color textColor,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, color: textColor)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('关于我们'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('身份验证器 Authenticator'),
            const SizedBox(height: 8),
            const Text('版本: 1.0.0'),
            const SizedBox(height: 8),
            const Text(
              '基于TOTP标准的开源身份验证器应用，支持本地离线生成动态验证码。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
