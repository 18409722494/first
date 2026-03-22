import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 帮助与支持详情页面
/// 显示和管理帮助与支持相关的功能
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  /// 显示意见反馈对话框
  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('意见反馈'),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '请输入您的意见或建议',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (feedbackController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('请输入反馈内容')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('反馈提交成功，感谢您的建议')),
                );
              });
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '行李管理系统',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.luggage,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: 16),
        const Text('行李管理系统是一款专为航空地勤人员设计的行李追踪和管理工具。'),
        const SizedBox(height: 8),
        const Text('© 2026 行李管理系统 版权所有'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮助与支持'),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.help_outline, size: Responsive.iconSize(context, 24)),
                  title: Text('使用帮助', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('使用帮助功能已启用')),
                    );
                  },
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.feedback_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text('意见反馈', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _showFeedbackDialog(context),
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.info_outline, size: Responsive.iconSize(context, 24)),
                  title: Text('关于', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _showAboutDialog(context),
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.phone_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text('联系我们', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  subtitle: Text('400-123-4567', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () async {
                    final status = await Permission.phone.request();

                    if (status.isGranted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('联系我们功能已启用')),
                      );
                    } else if (status.isDenied) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('需要电话权限才能拨打电话')),
                      );
                    } else if (status.isPermanentlyDenied) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('权限被拒绝'),
                          content: const Text('电话权限已被永久拒绝，请在系统设置中开启'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                openAppSettings();
                              },
                              child: const Text('去设置'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
          Card(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '帮助与支持说明',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    '• 使用帮助：查看应用的使用指南和常见问题\n• 意见反馈：提交您对应用的意见和建议\n• 关于：查看应用的版本信息和版权声明\n• 联系我们：获取客服支持',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 13),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
