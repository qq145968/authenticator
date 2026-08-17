import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../data/models/account.dart';

class ManualAddPage extends StatefulWidget {
  const ManualAddPage({super.key});

  @override
  State<ManualAddPage> createState() => _ManualAddPageState();
}

class _ManualAddPageState extends State<ManualAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _labelController = TextEditingController();
  final _secretController = TextEditingController();
  String _selectedCategory = '未分类';
  int _digits = 6;
  int _period = 30;

  final List<String> _categories = ['未分类', '工作', '学习', '社交', '金融', '其他'];

  @override
  void dispose() {
    _issuerController.dispose();
    _labelController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final account = Account(
      issuer: _issuerController.text.trim(),
      label: _labelController.text.trim().isEmpty
          ? _issuerController.text.trim()
          : _labelController.text.trim(),
      secret: _secretController.text.trim().replaceAll(' ', '').toUpperCase(),
      digits: _digits,
      period: _period,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<AppProvider>().addAccount(account);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手动输入'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '请输入服务商提供的2FA密钥（Base32编码）',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('发行方 *', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  hintText: '例如: Google, GitHub, Amazon',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入发行方名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('账户名', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  hintText: '例如: user@example.com',
                ),
              ),
              const SizedBox(height: 16),
              Text('密钥 *', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secretController,
                decoration: const InputDecoration(
                  hintText: '例如: JBSWY3DPEHPK3PXP',
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入密钥';
                  }
                  final cleaned = value.trim().replaceAll(' ', '').toUpperCase();
                  if (!RegExp(r'^[A-Z2-7]+$').hasMatch(cleaned)) {
                    return '密钥格式不正确，应为Base32编码';
                  }
                  if (cleaned.length < 16) {
                    return '密钥长度不足';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('分类', style: AppTextStyles.body),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primaryLighter,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('位数', style: AppTextStyles.body),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _digits,
                          decoration: const InputDecoration(),
                          items: [6, 7, 8].map((d) => DropdownMenuItem(
                            value: d,
                            child: Text('$d 位'),
                          )).toList(),
                          onChanged: (v) => setState(() => _digits = v ?? 6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('刷新周期', style: AppTextStyles.body),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _period,
                          decoration: const InputDecoration(),
                          items: [15, 30, 60].map((p) => DropdownMenuItem(
                            value: p,
                            child: Text('$p 秒'),
                          )).toList(),
                          onChanged: (v) => setState(() => _period = v ?? 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('添加账户'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
