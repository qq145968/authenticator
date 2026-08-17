import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.description,
                  title: '用户协议',
                  textColor: textColor,
                  onTap: () => _openUrl('https://example.com/user-agreement'),
                ),
                const Divider(indent: 16),
                _buildMenuItem(
                  context: context,
                  icon: Icons.shield,
                  title: '隐私政策',
                  textColor: textColor,
                  onTap: () => _openUrl('https://example.com/privacy-policy'),
                ),
                const Divider(indent: 16),
                _buildMenuItem(
                  context: context,
                  icon: Icons.extension,
                  title: '第三方SDK清单',
                  textColor: textColor,
                  onTap: () => _openUrl('https://example.com/sdk-list'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: const [
                Text(
                  'V1.0.1',
                  style: TextStyle(fontSize: 14, color: AppColors.textHint),
                ),
                SizedBox(height: 4),
                Text(
                  '备案号: 粤ICP备2026074649号-1A',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, color: textColor)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
