import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TrialExpirationDialog extends StatelessWidget {
  final int remainingDays;

  const TrialExpirationDialog({super.key, required this.remainingDays});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.hourglass_bottom, color: AppColors.primary, size: 40),
                  Positioned(
                    bottom: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '试用还有$remainingDays天结束',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '体验结束后，查看验证码需要会员权限。\n'
              '如果不想继续使用，请在体验结束前前往对应平台关闭二次验证，避免影响登录。',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/vip');
                    },
                    child: const Text('查看会员权益'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('我知道了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
