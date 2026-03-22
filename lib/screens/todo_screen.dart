import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'damage_report_screen.dart';
import 'overweight_screen.dart';
import 'contact_passenger_screen.dart';

/// 待办事项页面
/// 展示需要处理的异常行李列表
class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '需要处理的异常行李',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < MockData.todoItems.length; i++) ...[
                    if (i > 0) SizedBox(height: Responsive.spacing(context, 8)),
                    _buildTodoItem(
                      context,
                      title: MockData.todoItems[i]['title'] as String,
                      description: MockData.todoItems[i]['description'] as String,
                      icon: _iconFromString(MockData.todoItems[i]['icon'] as String),
                      color: Color(MockData.todoItems[i]['color'] as int),
                      type: MockData.todoItems[i]['type'] as String,
                      tagNumber: MockData.todoItems[i]['tagNumber'] as String,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建待办事项项
  Widget _buildTodoItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String type,
    required String tagNumber,
  }) {
    return GestureDetector(
      onTap: () {
        if (type == MockData.todoTypeDamage) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DamageReportScreen(
                luggageId: MockData.createByTagNumber(tagNumber).id,
              ),
            ),
          );
        } else if (type == MockData.todoTypeOverweight) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OverweightScreen(
                luggage: MockData.createByTagNumber(tagNumber),
              ),
            ),
          );
        } else if (type == MockData.todoTypeContact) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactPassengerScreen(
                luggage: MockData.createByTagNumber(tagNumber),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: color.withValues(alpha: 0.1),
        ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color.withValues(alpha: 0.2),
              ),
              child: Icon(icon, size: Responsive.iconSize(context, 18), color: color),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'report_problem':
        return Icons.report_problem;
      case 'scale':
        return Icons.scale;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.help;
    }
  }
}
