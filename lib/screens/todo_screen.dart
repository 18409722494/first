import 'package:flutter/material.dart';
import '../models/luggage.dart';
import 'damage_report_screen.dart';
import 'overweight_screen.dart';
import 'contact_passenger_screen.dart';

/// 待办事项页面
/// 展示需要处理的异常行李列表
class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '需要处理的异常行李',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTodoItem(
                    context,
                    title: '行李破损登记',
                    description: '行李标签号: BA12345 需要登记破损情况',
                    icon: Icons.report_problem,
                    color: Colors.red,
                    type: 'damage',
                  ),
                  const SizedBox(height: 12),
                  _buildTodoItem(
                    context,
                    title: '行李超重处理',
                    description: '行李标签号: BA67890 需要重新称重',
                    icon: Icons.scale,
                    color: Colors.orange,
                    type: 'overweight',
                  ),
                  const SizedBox(height: 12),
                  _buildTodoItem(
                    context,
                    title: '联系旅客',
                    description: '旅客行李无人认领，需要联系',
                    icon: Icons.phone,
                    color: Colors.blue,
                    type: 'contact',
                  ),
                  const SizedBox(height: 12),
                  _buildTodoItem(
                    context,
                    title: '行李破损登记',
                    description: '行李标签号: BA24680 需要登记破损情况',
                    icon: Icons.report_problem,
                    color: Colors.red,
                    type: 'damage',
                  ),
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
    BuildContext context,
    {required String title,
      required String description,
      required IconData icon,
      required Color color,
      required String type,
    })
  {
    return GestureDetector(
      onTap: () {
        // 根据异常类型智能跳转
        if (type == 'damage') {
          // 跳转至破损登记详情页
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DamageReportScreen(
                luggage: _mockLuggage(description),
              ),
            ),
          );
        } else if (type == 'overweight') {
          // 跳转至超重费用/称重页
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OverweightScreen(
                luggage: _mockLuggage(description),
              ),
            ),
          );
        } else if (type == 'contact') {
          // 跳转至旅客联系/认领页
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactPassengerScreen(
                luggage: _mockLuggage(description),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// 模拟行李数据
  Luggage _mockLuggage(String description) {
    // 从描述中提取行李标签号
    final tagNumberMatch = RegExp(r'行李标签号: (BA\d+)').firstMatch(description);
    final tagNumber = tagNumberMatch?.group(1) ?? 'BA00000';

    return Luggage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tagNumber: tagNumber,
      flightNumber: 'CA1234',
      passengerName: '旅客姓名',
      weight: 25.0,
      status: LuggageStatus.checkIn,
      checkInTime: DateTime.now(),
      lastUpdated: DateTime.now(),
      destination: '北京',
      notes: '',
    );
  }
}
