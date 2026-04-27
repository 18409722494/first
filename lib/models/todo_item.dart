import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 待办事项类型
enum TodoType {
  damage,
  unclaimed,
  unprocessed,
}

/// 待办事项数据模型
///
/// 数据来源：
///   - damage      → abnormal-baggage 表（EvidenceService）
///   - unclaimed   → luggage 表，按状态/时间筛选（BaggageApiService）
///   - unprocessed → 航班未处理行李（从 /baggage/unprocessed 获取）
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
  /// 关联航班号（unprocessed 类型用）
  final String? flightNumber;

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
    this.flightNumber,
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
      icon: Icons.warning_amber,
      color: AppColors.error,
      tagNumber: baggageNumber,
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
      color: AppColors.info,
      tagNumber: tagNumber,
      luggageId: luggageId,
      timestamp: arrivedAt,
    );
  }

  /// 从未处理行李构造
  factory TodoItem.fromUnprocessed({
    required String baggageNumber,
    required String flightNumber,
    required DateTime timestamp,
  }) {
    return TodoItem(
      id: 'unprocessed_${baggageNumber}_$flightNumber',
      type: TodoType.unprocessed,
      title: '待处理行李',
      description: '行李号: $baggageNumber',
      icon: Icons.inventory_2_outlined,
      color: AppColors.warning,
      tagNumber: baggageNumber,
      flightNumber: flightNumber,
      timestamp: timestamp,
    );
  }
}
