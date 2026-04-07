import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 系统设置详情页面
class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {

  void _showLanguageDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final locales = [
      {'code': 'zh_CN', 'label': '简体中文'},
      {'code': 'en_US', 'label': 'English'},
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('语言设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: locales.map((item) {
            final isSelected = settings.locale.languageCode == item['code']!.split('_')[0];
            return ListTile(
              title: Text(item['label'] as String),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                final code = item['code'] as String;
                final parts = code.split('_');
                settings.setLocale(Locale(parts[0], parts.length > 1 ? parts[1] : ''));
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('主题设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(
              context,
              dialogContext,
              icon: Icons.brightness_5,
              label: '浅色模式',
              mode: ThemeMode.light,
              current: settings.themeMode,
              settings: settings,
            ),
            _themeOption(
              context,
              dialogContext,
              icon: Icons.brightness_2,
              label: '深色模式',
              mode: ThemeMode.dark,
              current: settings.themeMode,
              settings: settings,
            ),
            _themeOption(
              context,
              dialogContext,
              icon: Icons.brightness_auto,
              label: '跟随系统',
              mode: ThemeMode.system,
              current: settings.themeMode,
              settings: settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext ctx,
    BuildContext dialogCtx, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode current,
    required SettingsProvider settings,
  }) {
    final isSelected = current == mode;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(dialogCtx);
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理应用缓存吗？这将删除应用���临时数据，但不会影响您的个人数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
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

  String _getCurrentLanguageLabel(Locale locale) {
    if (locale.languageCode == 'zh') return '简体中文';
    if (locale.languageCode == 'en') return 'English';
    return '简体中文';
  }

  String _getCurrentThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.notifications_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('通知设置', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () => _showNotificationSettingsDialog(context),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.language_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('语言设置', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCurrentLanguageLabel(settings.locale),
                            style: TextStyle(color: Colors.grey[600], fontSize: Responsive.fontSize(context, 14)),
                          ),
                          SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () => _showLanguageDialog(context),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.dark_mode_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('主题设置', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCurrentThemeLabel(settings.themeMode),
                            style: TextStyle(color: Colors.grey[600], fontSize: Responsive.fontSize(context, 14)),
                          ),
                          SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () => _showThemeDialog(context),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.storage_outlined, size: Responsive.iconSize(context, 24)),
                      title: Text('清理缓存', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      subtitle: Text('12.3 MB', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: _showClearCacheDialog,
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
                        '系统设置说明',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                      Text(
                        '• 通知设置可以控制应用的通知类型\n• 语言设置可以更改应用的显示语言\n• 主题设置可以切换深色/浅色模式\n• 清理缓存可以释放应用占用的存储空间',
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

  void _showNotificationSettingsDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('通知设置'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('行李状态更新', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  value: settings.notifyLuggageStatus,
                  onChanged: (value) {
                    settings.setNotifyLuggageStatus(value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text('系统通知', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  value: settings.notifySystem,
                  onChanged: (value) {
                    settings.setNotifySystem(value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text('异常提醒', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  value: settings.notifyAbnormal,
                  onChanged: (value) {
                    settings.setNotifyAbnormal(value);
                    setDialogState(() {});
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('确定'),
              ),
            ],
          );
        },
      ),
    );
  }
}