import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'luggage_map_screen.dart';
import 'package:flutter_echarts/flutter_echarts.dart';

/// 个人中心界面
/// 显示用户信息、账户设置、应用设置等
/// 提供退出登录功能
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('员工中心'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 用户信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          user?.username.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.username ?? '未知用户',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (user?.email != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user!.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 功能列表
              _buildSectionTitle(context, '账户信息'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('员工工号'),
                      subtitle: Text(
                        user?.id != null ? '******${user!.id.substring(user.id.length - 4)}' : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        _showEmployeeIdDialog(context, user?.id ?? '-');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('工作邮箱'),
                      subtitle: Text(
                        user?.email != null ? '******${user!.email.substring(user.email.indexOf('@'))}' : '未设置',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('员工姓名'),
                      subtitle: Text(
                        user?.username != null ? '******${user!.username.substring(user.username.length - 2)}' : '未设置',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(context, '设置'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('通知设置'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('通知设置功能开发中')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: const Text('语言设置'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '简体中文',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('语言设置功能开发中')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('主题设置'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('主题设置功能开发中')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(context, '其他'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: const Text('行李地图'),
                      subtitle: const Text('查看行李位置分布'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LuggageMapScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('帮助与反馈'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('帮助与反馈功能开发中')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('关于'),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: '行李管理系统',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(
                            Icons.luggage,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 退出登录按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('确认退出'),
                        content: const Text('确定要退出登录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('取消'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('退出'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('退出登录'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showEmployeeIdDialog(BuildContext context, String employeeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('员工工号'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              employeeId,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '点击下方按钮复制工号',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('复制'),
          ),
        ],
      ),
    );
  }
}
