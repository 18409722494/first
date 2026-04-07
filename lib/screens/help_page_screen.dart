import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 使用帮助页面
class HelpPageScreen extends StatelessWidget {
  const HelpPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final helps = [
      _HelpItem(
        icon: Icons.qr_code_scanner,
        title: '扫码操作',
        content: '在底部导航栏点击「扫码」进入扫码界面，点击扫描按钮对准行李上的二维码即可识别。识别成功后会自动跳转到行李详情页，您可以在此更新行李位置或状态。',
      ),
      _HelpItem(
        icon: Icons.list_alt,
        title: '行李列表',
        content: '在底部导航栏点击「行李」进入行李列表页。您可以通过搜索框按行李标签号或旅客姓名进行搜索，也可以通过筛选按钮按行李状态进行筛选。',
      ),
      _HelpItem(
        icon: Icons.warning_amber,
        title: '破损登记',
        content: '发现行李破损时，在扫码结果页面点击「破损登记」按钮，或在行李详情页点击「登记破损」按钮。上传破损照片并填写描述后提交，系统会自动生成破损记录并通知相关人员。',
      ),
      _HelpItem(
        icon: Icons.scale,
        title: '超重处理',
        content: '当待办事项中出现超重行李提示时，点击该条进入超重处理页面。核对行李重量，确认超重后选择收费方式（现金/电子支付），完成后更新行李状态。',
      ),
      _HelpItem(
        icon: Icons.phone,
        title: '联系旅客',
        content: '当待办事项中出现无人认领行李提示时，点击该条进入联系旅客页面。系统会显示旅客的联系方式，点击呼叫按钮可直接拨打电话。联系成功后更新行李状态为「已交付」。',
      ),
      _HelpItem(
        icon: Icons.edit_note,
        title: '提交反馈',
        content: '如果您在使用过程中遇到问题或有改进建议，可以在「我的 → 帮助与支持 → 意见反馈」中填写并提交。我们会认真处理每一条反馈。',
      ),
      _HelpItem(
        icon: Icons.dark_mode,
        title: '主题与语言',
        content: '在「我的 → 系统设置 → 主题设置」中可切换浅色/深色/跟随系统三种模式。在「语言设置」中可切换简体中文或 English。设置会自动保存。',
      ),
      _HelpItem(
        icon: Icons.notifications,
        title: '通知提醒',
        content: '应用会在出现待办事项时推送通知，包括超重行李、无人认领行李、破损登记等。在「系统设置 → 通知设置」中可以分别开启或关闭各类型的通知。',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('使用帮助'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        itemCount: helps.length,
        itemBuilder: (context, index) {
          final item = helps[index];
          return Padding(
            padding: EdgeInsets.only(bottom: Responsive.spacing(context, AppSpacing.sm)),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, size: 20, color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, 15),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                    Text(
                      item.content,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: Responsive.fontSize(context, 13),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HelpItem {
  final IconData icon;
  final String title;
  final String content;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.content,
  });
}