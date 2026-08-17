import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InvoiceFormPage extends StatefulWidget {
  const InvoiceFormPage({super.key});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final _headerController = TextEditingController();
  final _messageController = TextEditingController();
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    _headerController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: '发票抬头信息 *',
            isDark: isDark,
            child: TextField(
              controller: _headerController,
              maxLines: 4,
              decoration: _inputDecoration(isDark).copyWith(
                hintText: '请填写发票抬头、税号、公司名称、地址电话、开户行及账号等信息',
              ),
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '留言（选填）',
            isDark: isDark,
            child: TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: _inputDecoration(isDark).copyWith(
                hintText: '可补充订单号、订单金额、付款时间或其他开票备注',
              ),
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '付款凭证 *',
            isDark: isDark,
            child: _buildImageUpload(isDark),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('提交'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required bool isDark, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkCard : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildImageUpload(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '请上传微信或支付宝的付款凭证（包含付款时间及商户订单号）',
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _imagePaths.length < 3 ? _pickImage : null,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.primary, size: 28),
                const SizedBox(height: 4),
                Text(
                  '添加图片',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'JPG、PNG、WebP、SVG，最大 5MB',
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
            const Spacer(),
            Text(
              '${_imagePaths.length}/3',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
      ],
    );
  }

  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('请通过系统相册选择图片'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _submit() {
    if (_headerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请填写发票抬头信息'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请上传付款凭证'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('发票申请已提交，请等待处理'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    _headerController.clear();
    _messageController.clear();
  }
}
