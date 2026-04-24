import 'package:flutter/material.dart';
import '../models/luggage.dart';

/// 行李相关的UI工具函数
/// 颜色定义已移至 [LuggageStatus.color] 和 [LuggageStatus.bgColor]
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
  /// 优先使用枚举自身属性
  static Color getStatusColor(LuggageStatus status) {
    return status.color;
  }

  /// 获取行李状态的浅色背景（适合Chip/Container背景）
  static Color getStatusBgColor(LuggageStatus status) {
    return status.bgColor;
  }

  /// 获取行李状态的主颜色（根据字符串状态键）
  static Color getStatusColorByKey(String statusKey) {
    final status = LuggageStatus.values.firstWhere(
      (s) => s.name == statusKey,
      orElse: () => LuggageStatus.checkIn,
    );
    return status.color;
  }

  /// 获取行李状态的浅色背景（根据字符串状态键）
  static Color getStatusBgColorByKey(String statusKey) {
    final status = LuggageStatus.values.firstWhere(
      (s) => s.name == statusKey,
      orElse: () => LuggageStatus.checkIn,
    );
    return status.bgColor;
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

  /// 清理位置数据中的乱码字符
  /// 移除控制字符、非法Unicode代理对等，只保留可见字符
  static String cleanLocationString(String input) {
    if (input.isEmpty) return input;

    // 移除常见的控制字符和乱码模式
    String cleaned = input
        // 移除 Unicode 控制字符 (C0 控制字符)
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // 移除常见的乱码模式 (如 锟斤拷, 烫烫烫 等)
        .replaceAll(RegExp(r'锟斤拷|烫烫烫|\?{2,}'), '')
        // 移除零宽字符
        .replaceAll(RegExp(r'[\u200B-\u200F\uFEFF]'), '')
        // 移除 Unicode 代理对 (非法的 surrogate pairs)
        .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '')
        // 规范化空白字符
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 如果清理后为空或全是乱码，返回原始值（让用户知道有问题）
    if (cleaned.isEmpty) {
      return input;
    }

    return cleaned;
  }
}
