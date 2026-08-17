import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class PrivacyAgreementDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const PrivacyAgreementDialog({
    super.key,
    required this.onAccept,
    this.onDecline,
  });

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              '用户协议及隐私政策',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '感谢您使用Authenticator身份验证器！我们非常重视您的个人信息安全与隐私。为了向您提供更加优质的服务，我们可能需要使用某些权限。在您同意后，我们将依据相关规定收集和处理您的信息。如果您选择拒绝，可能会影响部分功能的使用。您可以通过阅读《用户协议》和《隐私政策》详细了解我们的服务及信息处理方式。我们的产品集成了部分第三方SDK。如需了解这些SDK的个人信息收集情况，请查阅《第三方SDK清单》。',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.65,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                Text('您可以通过阅读', style: TextStyle(fontSize: 14.5, color: subTextColor, height: 1.65)),
                _buildLink('《用户协议》', 'https://example.com/user-agreement'),
                Text('和', style: TextStyle(fontSize: 14.5, color: subTextColor, height: 1.65)),
                _buildLink('《隐私政策》', 'https://example.com/privacy'),
                Text('详细了解我们的服务及信息处理方式。', style: TextStyle(fontSize: 14.5, color: subTextColor, height: 1.65)),
              ],
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                Text('我们的产品集成了部分第三方SDK。如需了解这些SDK的个人信息收集情况，请查阅',
                    style: TextStyle(fontSize: 14.5, color: subTextColor, height: 1.65)),
                _buildLink('《第三方SDK清单》', 'https://example.com/sdk-list'),
                Text('。', style: TextStyle(fontSize: 14.5, color: subTextColor, height: 1.65)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onAccept,
                child: const Text('同意并继续', style: AppTextStyles.button),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (onDecline != null) {
                  onDecline!();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                '不同意',
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLink(String text, String url) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.5,
          color: AppColors.primary,
          decoration: TextDecoration.none,
          height: 1.65,
        ),
      ),
    );
  }
}
