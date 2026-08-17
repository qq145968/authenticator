import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/account.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getIconColor(String issuer) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final hash = issuer.hashCode;
    return colors[hash % colors.length];
  }

  Future<void> _showRestoreDialog(Account account) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('恢复账户'),
        content: Text('确定要恢复 ${account.issuer} 的验证码账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('恢复', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await context.read<AppProvider>().restoreAccount(account.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('账户已恢复'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _showPermanentDeleteDialog(Account account) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('永久删除'),
        content: Text(
          '确定要永久删除 ${account.issuer} 的验证码账户吗？\n此操作无法撤销，删除后将无法生成该账户的动态验证码。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('永久删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await context.read<AppProvider>().permanentDeleteAccount(account.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已永久删除'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _showClearTrashDialog() async {
    final provider = context.read<AppProvider>();
    if (provider.deletedAccounts.isEmpty) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空回收站'),
        content: Text(
          '确定要永久删除回收站中的 ${provider.deletedAccounts.length} 个账户吗？\n此操作无法撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await provider.clearTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('回收站已清空'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final deletedAccounts = provider.deletedAccounts;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('回收站'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (deletedAccounts.isNotEmpty)
            IconButton(
              tooltip: '清空回收站',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _showClearTrashDialog,
            ),
        ],
      ),
      body: deletedAccounts.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: subTextColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '回收站中的账户可恢复到验证码列表，或永久删除。',
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: deletedAccounts.length,
                    itemBuilder: (context, index) {
                      final account = deletedAccounts[index];
                      return _buildTrashItem(account, textColor, subTextColor);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('回收站是空的', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              '左滑删除的验证码账户会出现在这里',
              style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashItem(Account account, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getIconColor(account.issuer).withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  account.issuer.isNotEmpty ? account.issuer.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.issuer,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.label,
                    style: TextStyle(fontSize: 12, color: subTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '删除于 ${_formatDate(account.deletedAt ?? account.updatedAt)}',
                        style: TextStyle(fontSize: 11, color: subTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: Icons.restore_outlined,
                  color: AppColors.primary,
                  tooltip: '恢复',
                  onTap: () => _showRestoreDialog(account),
                ),
                const SizedBox(width: 6),
                _buildActionButton(
                  icon: Icons.delete_forever_outlined,
                  color: Colors.red,
                  tooltip: '永久删除',
                  onTap: () => _showPermanentDeleteDialog(account),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
