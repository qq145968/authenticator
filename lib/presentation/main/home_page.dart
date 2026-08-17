import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/utils/totp_utils.dart';
import '../../data/models/account.dart';
import '../login/login_page.dart';
import '../scan/scan_page.dart';
import '../manual_add/manual_add_page.dart';
import 'profile_page.dart';
import '../trash/trash_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToScan() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanPage()));
  }

  void _navigateToManualAdd() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualAddPage()));
  }

  void _navigateToLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
  }

  void _navigateToTrash() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashPage()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, provider, isDark),
          if (provider.isLoggedIn) _buildCategoryTabs(context, provider),
          Expanded(
            child: !provider.isLoggedIn
                ? _buildNotLoggedInState()
                : provider.accounts.isEmpty
                    ? _buildEmptyState()
                    : _buildAccountList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider, bool isDark) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '身份验证器',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Authenticator',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _navigateToTrash,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                              if (provider.hasDeletedAccounts)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _navigateToProfile,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '搜索账户...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context, AppProvider provider) {
    final categories = provider.categories;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = provider.selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => provider.selectCategory(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLighter : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _navigateToManualAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('登录后可添加或查看你的验证码', style: AppTextStyles.body),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                child: const Text('前往登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('还没有账户', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            const Text(
              '扫码或手动输入密钥，开始保护你的账户',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _navigateToScan,
                child: const Text('添加第一个账户'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList(AppProvider provider) {
    List<Account> accounts;
    if (_searchQuery.isNotEmpty) {
      accounts = provider.searchAccounts(_searchQuery);
    } else {
      accounts = provider.filteredAccounts;
    }

    if (accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? '未找到匹配的账户' : '暂无账户',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Dismissible(
          key: ValueKey('acc-${account.id}'),
          direction: DismissDirection.endToStart,
          dismissThresholds: const {DismissDirection.endToStart: 0.5},
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              return await _showDismissConfirmDialog(account);
            }
            return false;
          },
          onDismissed: (direction) {
            context.read<AppProvider>().softDeleteAccount(account.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已将 ${account.issuer} 移至回收站'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                action: SnackBarAction(
                  label: '撤销',
                  onPressed: () => context.read<AppProvider>().restoreAccount(account.id!),
                ),
              ),
            );
          },
          background: _buildDismissBackground(),
          child: _AccountCard(
            account: account,
            totpResult: provider.getTotp(account),
            onDelete: () => _showDeleteDialog(account),
            onCopy: (code) => _copyCode(code),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.delete_outline, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text(
            '删除',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDismissConfirmDialog(Account account) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除账户'),
        content: Text(
          '确定要删除 ${account.issuer} 的验证码账户吗？\n\n删除后将移入回收站，您可以在回收站中恢复或永久删除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('验证码已复制'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDeleteDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除账户'),
        content: Text(
          '确定要删除 ${account.issuer} 的验证码账户吗？\n\n删除后将移入回收站，您可以在回收站中恢复或永久删除。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().softDeleteAccount(account.id!);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final TotpResult? totpResult;
  final VoidCallback onDelete;
  final Function(String) onCopy;

  const _AccountCard({
    required this.account,
    required this.totpResult,
    required this.onDelete,
    required this.onCopy,
  });

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

  @override
  Widget build(BuildContext context) {
    final code = totpResult?.code ?? '------';
    final remaining = totpResult?.remainingSeconds ?? 30;
    final period = totpResult?.period ?? 30;
    final progress = remaining / period;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onCopy(code),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getIconColor(account.issuer),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    account.issuer.isNotEmpty
                        ? account.issuer.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.issuer, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(account.label, style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Text(
                      TotpUtils.formatCode(code),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: AppColors.primary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onLongPress: onDelete,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remaining <= 5 ? Colors.red : AppColors.primary,
                        ),
                      ),
                      Text(
                        '$remaining',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: remaining <= 5 ? Colors.red : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
