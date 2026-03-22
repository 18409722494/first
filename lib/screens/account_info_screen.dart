import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 账户信息详情页面
/// 显示员工的详细账户信息
class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户信息'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return ListView(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.badge_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('员工工号', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      subtitle: Text(
                        user?.id ?? '-',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.email_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('工作邮箱', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      subtitle: Text(
                        user?.email ?? '未设置',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.person_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('员工姓名', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      subtitle: Text(
                        user?.username ?? '未知用户',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
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
                        '账户信息说明',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                      Text(
                        '• 员工工号是您在系统中的唯一标识\n• 工作邮箱用于系统通知和重要信息发送\n• 员工姓名将显示在您的个人资料中',
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
          );
        },
      ),
    );
  }
}
