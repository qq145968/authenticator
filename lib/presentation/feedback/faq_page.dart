import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'feedback_form_page.dart';
import 'invoice_form_page.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('常见问题'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFeedbackCenterCard(),
          _buildTabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const FeedbackFormPage(),
                const InvoiceFormPage(),
                _buildMyFeedback(isDark),
                _buildFaqList(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCenterCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '反馈中心',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '您提交的反馈会在1-3个工作日收到回复，可前往「我的反馈」查看处理进度',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(4),
        tabs: [
          _buildTab('提交反馈'),
          _buildTab('开具发票'),
          _buildTab('我的反馈'),
          _buildTab('常见问题'),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildMyFeedback(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text('暂无反馈记录', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqList(bool isDark) {
    final faqItems = _getFaqItems();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqItems.length,
      itemBuilder: (context, index) {
        final item = faqItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              item.question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.answer,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_FaqItem> _getFaqItems() {
    return [
      _FaqItem(
        question: '安全提示',
        answer: '试用期后，非会员访问权限会受限，系统不保证继续提供密钥查看。',
      ),
      _FaqItem(
        question: '如何联系我们?',
        answer: '为了更快核对问题，建议优先使用「提交反馈」功能，并补充问题描述、截图和必要的设备信息。\n\n'
            '如果您暂时不方便在页面中提交反馈，也可以发送邮件到：gs_help@outlook.com',
      ),
      _FaqItem(
        question: '验证码为什么验证失败?',
        answer: '请重点检查：\n'
            '• 设备时间是否自动同步\n'
            '• 当前验证码是否已超过有效时间\n'
            '• 目标平台保存的密钥或参数是否与 App 内一致',
      ),
      _FaqItem(
        question: '验证码记录不见了怎么处理?',
        answer: '请检查回收站中是否有最近删除的记录。打开「设置」→「回收站」查看并恢复。',
      ),
      _FaqItem(
        question: '最近删除中的密钥能恢复吗?',
        answer: '可以。打开「设置」→「最近删除」，确认记录无误后执行恢复。',
      ),
      _FaqItem(
        question: '多设备同步安全吗?',
        answer: '支持在安卓、鸿蒙设备上通过同一微信授权登录并同步数据。请确保设备和登录账号可信。',
      ),
      _FaqItem(
        question: '换新手机后如何迁移?',
        answer: '在新设备安装最新版 App，使用原微信授权登录后，验证码数据会同步显示。',
      ),
      _FaqItem(
        question: '可以保存多个账号吗?',
        answer: '可以。你可以为不同平台、邮箱或云服务分别保存验证码账号。',
      ),
    ];
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
