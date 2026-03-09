import 'package:flutter/material.dart';

/// 系统设置详情页面
/// 显示和管理系统相关的设置
class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _systemNotificationsEnabled = true;
  bool _errorNotificationsEnabled = true;

  /// 显示通知设置对话框
  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('通知设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('行李状态更新'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('系统通知'),
              trailing: Switch(
                value: _systemNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _systemNotificationsEnabled = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('异常提醒'),
              trailing: Switch(
                value: _errorNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _errorNotificationsEnabled = value;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示清理缓存对话框
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理应用缓存吗？这将删除应用的临时数据，但不会影响您的个人数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              // 先关闭对话框
              Navigator.pop(dialogContext);
              // 对话框关闭后，使用主上下文显示成功提示
              Future.delayed(const Duration(milliseconds: 100), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存清理成功')),
                );
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('通知设置'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showNotificationSettingsDialog,
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
                    // 语言设置功能
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('语言设置功能已启用')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('主题设置'),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isDarkMode ? '深色模式已开启' : '深色模式已关闭')),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('清理缓存'),
                  subtitle: const Text('12.3 MB'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showClearCacheDialog,
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
                    '系统设置说明',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 通知设置可以控制应用的通知类型\n• 语言设置可以更改应用的显示语言\n• 主题设置可以切换深色/浅色模式\n• 清理缓存可以释放应用占用的存储空间',
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
