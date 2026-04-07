import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 待办事项类型
enum TodoType {
  damage,
  overweight,
  unclaimed,
}

/// 待办事项数据模型
/// 数据来源：
///   - damage    → abnormal-baggage 表（EvidenceService）
///   - overweight → luggage 表，按重量筛选（BaggageApiService）
///   - unclaimed → luggage 表，按状态/时间筛选（BaggageApiService）
class TodoItem {
  /// 唯一标识（来源类型 + 来源 id）
  final String id;
  final TodoType type;
  /// 显示标题
  final String title;
  /// 显示副标题/描述
  final String description;
  /// 图标
  final IconData icon;
  /// 主题色
  final Color color;
  /// 关联行李标签号
  final String tagNumber;
  /// 关联行李 id（供跳转详情用）
  final String? luggageId;
  /// 发生时间
  final DateTime timestamp;

  const TodoItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tagNumber,
    this.luggageId,
    required this.timestamp,
  });

  /// 从破损行李记录构造
  factory TodoItem.fromAbnormalBaggage({
    required String id,
    required String baggageNumber,
    required String damageDescription,
    required DateTime timestamp,
    String? luggageId,
  }) {
    return TodoItem(
      id: 'damage_$id',
      type: TodoType.damage,
      title: '行李破损登记',
      description: damageDescription.isEmpty
          ? '行李标签号: $baggageNumber 存在破损'
          : '$baggageNumber — $damageDescription',
      icon: Icons.report_problem,
      color: Colors.red,
      tagNumber: baggageNumber,
      luggageId: luggageId,
      timestamp: timestamp,
    );
  }

  /// 从超重行李构造
  factory TodoItem.fromOverweightLuggage({
    required String tagNumber,
    required String luggageId,
    required double weight,
    required DateTime timestamp,
  }) {
    final overweightKg = weight - AppConstants.freeBaggageWeightKg;
    return TodoItem(
      id: 'overweight_${luggageId}_$timestamp',
      type: TodoType.overweight,
      title: '行李超重处理',
      description:
          '$tagNumber 超出免费额度 ${overweightKg.toStringAsFixed(1)} kg，需补缴费用',
      icon: Icons.scale,
      color: Colors.orange,
      tagNumber: tagNumber,
      luggageId: luggageId,
      timestamp: timestamp,
    );
  }

  /// 从无人认领行李构造
  factory TodoItem.fromUnclaimedLuggage({
    required String tagNumber,
    required String luggageId,
    required String passengerName,
    required DateTime arrivedAt,
    int unclaimedHours = 24,
  }) {
    return TodoItem(
      id: 'unclaimed_${luggageId}_$arrivedAt',
      type: TodoType.unclaimed,
      title: '联系旅客（无人认领）',
      description: '$tagNumber（旅客: $passengerName）到达超过 $unclaimedHours 小时未认领',
      icon: Icons.phone,
      color: Colors.blue,
      tagNumber: tagNumber,
      luggageId: luggageId,
      timestamp: arrivedAt,
    );
  }
}
