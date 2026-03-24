import 'package:flutter/material.dart';
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
    final hasPermission = await PermissionService.requestCamera(context);

    if (!mounted) return;

    if (hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('快速扫描功能已启用')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('快捷功能'),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        children: [
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
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('排班表'),
                  subtitle: const Text('查看工作安排'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('排班表功能已启用')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: const Text('工作统计'),
                  subtitle: const Text('查看工作数据统计'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('工作统计功能已启用')),
                    );
                  },
                ),
                const Divider(height: 1),
                // ==================== 相机权限 - 使用 PermissionService ====================
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner_outlined),
                  title: const Text('快速扫描'),
                  subtitle: const Text('直接进入扫描界面'),
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
                    '快捷功能说明',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: Responsive.fontSize(context, 15),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 6)),
                  Text(
                    '• 行李地图：查看行李的实时位置分布\n• 排班表：查看您的工作安排和排班情况\n• 工作统计：查看您的工作数据和统计信息\n• 快速扫描：直接进入二维码扫描界面，方便快速处理行李',
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
