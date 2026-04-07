import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
  String _getCurrentLanguageLabel(BuildContext context, Locale locale) {
    final l10n = AppLocalizations.of(context)!;
    if (locale.languageCode == 'zh') return l10n.simplifiedChinese;
    if (locale.languageCode == 'en') return l10n.english;
    return l10n.simplifiedChinese;
  }

  String _getCurrentThemeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemMode;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.languageSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.simplifiedChinese),
              trailing: settings.locale.languageCode == 'zh'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                settings.setLocale(const Locale('zh', 'CN'));
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              trailing: settings.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                settings.setLocale(const Locale('en', 'US'));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.themeSettings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(
              dialogContext,
              icon: Icons.brightness_5,
              label: l10n.lightMode,
              mode: ThemeMode.light,
              current: settings.themeMode,
              settings: settings,
            ),
            _themeOption(
              dialogContext,
              icon: Icons.brightness_2,
              label: l10n.darkMode,
              mode: ThemeMode.dark,
              current: settings.themeMode,
              settings: settings,
            ),
            _themeOption(
              dialogContext,
              icon: Icons.brightness_auto,
              label: l10n.systemMode,
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

  void _showClearCacheDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.cacheClearedSuccess)),
                );
              });
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.systemSettingsTitle),
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
                      leading: Icon(Icons.notifications_outlined,
                          size: Responsive.iconSize(context, 24)),
                      title: Text(l10n.notificationSettings,
                          style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () => _showNotificationSettingsDialog(context),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.language_outlined,
                          size: Responsive.iconSize(context, 24)),
                      title: Text(l10n.languageSettings,
                          style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCurrentLanguageLabel(context, settings.locale),
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: Responsive.fontSize(context, 14)),
                          ),
                          SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () => _showLanguageDialog(context),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.dark_mode_outlined,
                          size: Responsive.iconSize(context, 24)),
                      title: Text(l10n.themeSettings,
                          style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCurrentThemeLabel(context, settings.themeMode),
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: Responsive.fontSize(context, 14)),
                          ),
                          SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                      onTap: () => _showThemeDialog(context),
                    ),
                    Divider(height: 1, indent: Responsive.spacing(context, 40)),
                    ListTile(
                      leading: Icon(Icons.storage_outlined,
                          size: Responsive.iconSize(context, 24)),
                      title: Text(l10n.clearCache,
                          style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                      subtitle: Text('12.3 MB',
                          style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () => _showClearCacheDialog(context),
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
                        l10n.systemSettingsNote,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                      Text(
                        l10n.systemSettingsNoteContent,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(l10n.notificationSettings),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(l10n.luggageStatusUpdate,
                      style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  value: settings.notifyLuggageStatus,
                  onChanged: (value) {
                    settings.setNotifyLuggageStatus(value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.systemNotification,
                      style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  value: settings.notifySystem,
                  onChanged: (value) {
                    settings.setNotifySystem(value);
                    setDialogState(() {});
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.abnormalAlert,
                      style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
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
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
      ),
    );
  }
}
