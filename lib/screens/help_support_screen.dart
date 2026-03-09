import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
              // 先关闭对话框
              Navigator.pop(dialogContext);
              // 对话框关闭后，使用主上下文显示成功提示
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
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('使用帮助'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    // 使用帮助功能
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('使用帮助功能已启用')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('意见反馈'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _showFeedbackDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('联系我们'),
                  subtitle: const Text('400-123-4567'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () async {
                    // 申请电话权限
                    final status = await Permission.phone.request();
                    
                    if (status.isGranted) {
                      // 权限已授予，显示成功提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('联系我们功能已启用')),
                      );
                    } else if (status.isDenied) {
                      // 权限被拒绝，显示提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('需要电话权限才能拨打电话')),
                      );
                    } else if (status.isPermanentlyDenied) {
                      // 权限被永久拒绝，引导用户去设置页
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
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '帮助与支持说明',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 使用帮助：查看应用的使用指南和常见问题\n• 意见反馈：提交您对应用的意见和建议\n• 关于：查看应用的版本信息和版权声明\n• 联系我们：获取客服支持',
                    style: TextStyle(
                      color: Colors.grey[600],
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
