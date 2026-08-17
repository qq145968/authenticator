import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VipUpgradePage extends StatefulWidget {
  const VipUpgradePage({super.key});

  @override
  State<VipUpgradePage> createState() => _VipUpgradePageState();
}

class _VipUpgradePageState extends State<VipUpgradePage> {
  int _selectedPlan = 1;
  int _selectedPayment = 0;

  final List<_PlanItem> _plans = [
    _PlanItem(name: '年会员', price: 78, dailyCost: '0.21', badge: null),
    _PlanItem(name: '永久会员', price: 98, dailyCost: '0.01', badge: '限时折扣', originalPrice: 198),
    _PlanItem(name: '月会员', price: 38, dailyCost: '1.27', badge: null),
  ];

  final List<_PaymentItem> _payments = [
    _PaymentItem(name: '微信支付', icon: Icons.wechat, color: AppColors.wechatGreen),
    _PaymentItem(name: '支付宝', icon: Icons.account_balance_wallet, color: const Color(0xFF1677FF)),
  ];

  final List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.all_inclusive,
      title: '无限账户数量',
      description: '添加任意多个TOTP验证码账户',
    ),
    _FeatureItem(
      icon: Icons.cloud_sync,
      title: '安全云端同步',
      description: '跨设备实时同步，永不丢失',
    ),
    _FeatureItem(
      icon: Icons.lock,
      title: '端到端加密',
      description: '零知识架构，数据只属于您',
    ),
    _FeatureItem(
      icon: Icons.block,
      title: '无广告体验',
      description: '干净纯粹，专注身份验证',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    _buildFeatureList(isDark),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildPaymentSection(),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.workspace_premium, color: AppColors.starYellow, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '升级高级会员',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.shield, color: Colors.white, size: 32),
              Positioned(
                bottom: 12,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: AppColors.primary, size: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '解锁全部高级特权',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '无限账户 · 云端同步 · 端到端加密',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(feature.icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature.description,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Row(
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        final isSelected = _selectedPlan == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlan = index),
            child: Container(
              margin: EdgeInsets.only(right: index < _plans.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (plan.badge != null)
                    Positioned(
                      top: -10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan.badge!,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (plan.originalPrice != null)
                        Text(
                          '¥${plan.originalPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        '¥${plan.price}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.dailyCost}/天',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '支付方式',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_payments.length, (index) {
            final payment = _payments[index];
            final isSelected = _selectedPayment == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPayment = index),
                child: Container(
                  margin: EdgeInsets.only(right: index < _payments.length - 1 ? 12 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? payment.color.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? payment.color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(payment.icon, color: payment.color, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        payment.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? payment.color : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          '支付即代表同意开通会员服务，开通后立即生效。',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('会员服务协议'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
              children: [
                TextSpan(text: '开通前请阅读'),
                TextSpan(
                  text: '《会员服务协议》',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已选择${_plans[_selectedPlan].name} · ${_payments[_selectedPayment].name}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('立即开通', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _PlanItem {
  final String name;
  final int price;
  final String dailyCost;
  final String? badge;
  final int? originalPrice;

  _PlanItem({
    required this.name,
    required this.price,
    required this.dailyCost,
    this.badge,
    this.originalPrice,
  });
}

class _PaymentItem {
  final String name;
  final IconData icon;
  final Color color;

  _PaymentItem({required this.name, required this.icon, required this.color});
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({required this.icon, required this.title, required this.description});
}
