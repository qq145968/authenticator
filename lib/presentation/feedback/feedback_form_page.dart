import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _issueTypeController = TextEditingController(text: '功能问题、产品建议与新功能需求');
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final List<String> _imagePaths = [];

  final List<String> _issueTypes = [
    '功能问题、产品建议与新功能需求',
    '登录/账户问题',
    '验证码生成异常',
    '键盘功能问题',
    '其他问题',
  ];

  @override
  void dispose() {
    _issueTypeController.dispose();
    _phoneController.dispose();
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
            label: '问题类型',
            isDark: isDark,
            child: DropdownButtonFormField<String>(
              value: _issueTypeController.text,
              items: _issueTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _issueTypeController.text = value;
                }
              },
              decoration: _inputDecoration(isDark),
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '手机号',
            isDark: isDark,
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(isDark).copyWith(hintText: '手机号'),
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '留言 *',
            isDark: isDark,
            child: TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: _inputDecoration(isDark).copyWith(hintText: '请尽量描述问题发生步骤'),
              style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: '问题截图',
            isDark: isDark,
            child: _buildImageUpload(isDark),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('提交反馈'),
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
        Text(
          '为方便快速定位和解决您的问题，请上传相关截图，最多上传 3 张截图',
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        const SizedBox(height: 4),
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
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请填写问题描述'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('反馈已提交，请等待回复'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    _messageController.clear();
    _phoneController.clear();
  }
}
