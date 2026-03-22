import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'luggage_map_screen.dart';

/// 快捷功能详情页面
/// 显示和管理快捷功能
class QuickFunctionsScreen extends StatelessWidget {
  const QuickFunctionsScreen({super.key});

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
                    // 排班表功能
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
                    // 工作统计功能
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('工作统计功能已启用')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner_outlined),
                  title: const Text('快速扫描'),
                  subtitle: const Text('直接进入扫描界面'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () async {
                    // 申请相机权限
                    final status = await Permission.camera.request();
                    
                    if (status.isGranted) {
                      // 权限已授予，显示成功提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('快速扫描功能已启用')),
                      );
                    } else if (status.isDenied) {
                      // 权限被拒绝，显示提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('需要相机权限才能使用扫描功能')),
                      );
                    } else if (status.isPermanentlyDenied) {
                      // 权限被永久拒绝，引导用户去设置页
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('权限被拒绝'),
                          content: const Text('相机权限已被永久拒绝，请在系统设置中开启'),
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
