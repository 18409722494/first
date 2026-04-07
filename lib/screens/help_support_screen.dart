import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/permission_service.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'help_page_screen.dart';

/// 帮助与支持详情页面
/// 显示和管理帮助与支持相关的功能
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  /// 显示意见反馈对话框
  void _showFeedbackDialog() {
    final l10n = AppLocalizations.of(context)!;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.feedback),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: l10n.feedbackHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (feedbackController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.feedbackEmpty)),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.feedbackSuccess)),
                );
              });
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.luggage,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: 16),
        Text(l10n.appDesc),
        const SizedBox(height: 8),
        Text(l10n.copyright),
      ],
    );
  }

  // ==================== 联系我们 - 使用 PermissionService ====================
  void _onContactUs() async {
    final l10n = AppLocalizations.of(context)!;
    final hasPermission = await PermissionService.requestPhone(context);

    if (!mounted) return;

    if (hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactUsEnabled)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpSupportTitle),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.help_outline, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.usageHelp, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpPageScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.feedback_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.feedback, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showFeedbackDialog,
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.info_outline, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.about, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showAboutDialog,
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                // ==================== 电话权限 - 使用 PermissionService ====================
                ListTile(
                  leading: Icon(Icons.phone_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.contactUs, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  subtitle: Text(l10n.contactPhone, style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _onContactUs,
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
                    l10n.helpSupportNote,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    l10n.helpSupportNoteContent,
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
