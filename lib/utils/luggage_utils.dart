import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../constants/app_constants.dart';

/// 行李相关的UI工具函数
/// 禁止在 screens/ 中重复定义 getStatusText / getStatusColor
class LuggageUtils {
  LuggageUtils._();

  /// 获取状态显示文本
  static String getStatusText(LuggageStatus status) {
    return status.displayName;
  }

  /// 获取状态显示文本（根据字符串状态键）
  static String getStatusTextByKey(String statusKey) {
    switch (statusKey) {
      case 'checkIn':
        return '已办理托运';
      case 'inTransit':
        return '运输中';
      case 'arrived':
        return '已到达';
      case 'delivered':
        return '已交付';
      case 'damaged':
        return '已损坏';
      case 'lost':
        return '已丢失';
      default:
        return statusKey;
    }
  }

  /// 获取行李状态的主颜色（适合标签/文字）
  static Color getStatusColor(LuggageStatus status) {
    final key = status.name;
    return AppConstants.luggageStatusColors[key] ?? Colors.grey;
  }

  /// 获取行李状态的浅色背景（适合Chip/Container背景）
  static Color getStatusBgColor(LuggageStatus status) {
    final key = status.name;
    return AppConstants.luggageStatusBgColors[key] ?? Colors.grey.shade100;
  }

  /// 获取行李状态的主颜色（根据字符串状态键）
  static Color getStatusColorByKey(String statusKey) {
    return AppConstants.getStatusColor(statusKey);
  }

  /// 获取行李状态的浅色背景（根据字符串状态键）
  static Color getStatusBgColorByKey(String statusKey) {
    return AppConstants.getStatusBgColor(statusKey);
  }

  /// 格式化相对时间（如"2小时前"）
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 7) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 从描述中提取行李标签号
  static String extractTagNumber(String description) {
    final match = RegExp(r'行李标签号: (BA\d+)').firstMatch(description);
    return match?.group(1) ?? 'BA00000';
  }
}
