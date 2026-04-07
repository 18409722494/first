import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/permission_service.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'luggage_map_screen.dart';

/// 快捷功能详情页面
/// 显示和管理快捷功能
class QuickFunctionsScreen extends StatefulWidget {
  const QuickFunctionsScreen({super.key});

  @override
  State<QuickFunctionsScreen> createState() => _QuickFunctionsScreenState();
}

class _QuickFunctionsScreenState extends State<QuickFunctionsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ==================== 快速扫描 - 使用 PermissionService ====================
  void _onQuickScan() async {
    final l10n = AppLocalizations.of(context)!;
    final hasPermission = await PermissionService.requestCamera(context);

    if (!mounted) return;

    if (hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quickScanEnabled)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickFunctionsTitle),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(l10n.luggageMap),
                  subtitle: Text(l10n.luggageMapDesc),
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
                  leading: const Icon(Icons.qr_code_scanner_outlined),
                  title: Text(l10n.quickScan),
                  subtitle: Text(l10n.quickScanDesc),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _onQuickScan,
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Card(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickFunctionsNote,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: Responsive.fontSize(context, 15),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 6)),
                  Text(
                    l10n.quickFunctionsNoteContent,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 12),
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
