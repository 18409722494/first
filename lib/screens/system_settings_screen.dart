import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 系统设置页面 - 基于 UI 设计风格 (Frame2989)
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.languageSettings,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.simplifiedChinese),
              trailing: settings.locale.languageCode == 'zh'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                settings.setLocale(const Locale('zh', 'CN'));
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              trailing: settings.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.themeSettings,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
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
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondaryLight),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.clearCache,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.clearCacheConfirm,
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.cacheClearedSuccess),
                    backgroundColor: AppColors.success,
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.luggage, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Text(
              'AirBaggage Pro',
              style: TextStyle(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本: v2.4.1',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
            SizedBox(height: 8),
            Text(
              'AirBaggage Pro 是一款专业的航空行李管理应用，'
              '为地勤人员提供高效的行李追踪与管理服务。',
              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 AirBaggage Pro. 保留所有权利。',
              style: TextStyle(color: AppColors.textHintLight, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final padMd = Responsive.padding(context, AppSpacing.md);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.systemSettingsTitle,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: EdgeInsets.all(padMd),
            children: [
              // 通知设置分组
              _buildSectionTitle('通知设置'),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _buildSettingsCard([
                _buildSwitchItem(
                  icon: Icons.notifications_outlined,
                  title: '推送通知',
                  value: settings.notifyLuggageStatus,
                  onChanged: (value) => settings.setNotifyLuggageStatus(value),
                ),
                _buildDivider(),
                _buildSwitchItem(
                  icon: Icons.warning_amber_outlined,
                  title: '异常行李提醒',
                  value: settings.notifyAbnormal,
                  onChanged: (value) => settings.setNotifyAbnormal(value),
                ),
                _buildDivider(),
                _buildSwitchItem(
                  icon: Icons.volume_up_outlined,
                  title: '声音提示',
                  value: settings.notifySystem,
                  onChanged: (value) => settings.setNotifySystem(value),
                ),
              ]),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              // 显示与语言分组
              _buildSectionTitle('显示与语言'),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _buildSettingsCard([
                _buildNavItem(
                  icon: Icons.language_outlined,
                  title: '语言',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCurrentLanguageLabel(context, settings.locale),
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textHintLight,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildDivider(),
                _buildNavItem(
                  icon: Icons.dark_mode_outlined,
                  title: '主题',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCurrentThemeLabel(context, settings.themeMode),
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textHintLight,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => _showThemeDialog(context),
                ),
              ]),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              // 存储分组
              _buildSectionTitle('存储'),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _buildSettingsCard([
                _buildNavItem(
                  icon: Icons.delete_outline,
                  title: '清除缓存',
                  subtitle: '当前缓存: 45.2 MB',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '清除',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () => _showClearCacheDialog(context),
                ),
              ]),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              // 关于分组
              _buildSettingsCard([
                _buildNavItem(
                  icon: Icons.info_outline,
                  title: '关于 AirBaggage Pro',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'v2.4.1',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textHintLight,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => _showAboutDialog(context),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppColors.borderLight,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey;
        }),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHintLight,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
