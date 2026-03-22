import 'package:flutter/material.dart';

/// 应用全局常量
/// 所有硬编码的配置值必须放在此处，禁止在业务代码中直接写死
class AppConstants {
  AppConstants._();

  // ==================== API配置 ====================
  /// API服务器基础地址
  static const String apiBaseUrl = 'http://8.137.145.195:3338';

  /// OSS图片上传端点
  static const String ossUploadEndpoint = '$apiBaseUrl/upload';

  // ==================== 行李超重规则 ====================
  /// 免费托运额度（千克）
  static const double freeBaggageWeightKg = 20.0;

  /// 超重单价（元/千克）
  static const double overweightFeePerKg = 100.0;

  /// 计算超重费用
  static double calculateOverweightFee(double actualWeightKg) {
    final overweight = actualWeightKg - freeBaggageWeightKg;
    return overweight > 0 ? overweight * overweightFeePerKg : 0.0;
  }

  // ==================== 分页配置 ====================
  /// 每页加载数量
  static const int pageSize = 20;

  /// 预加载阈值（距底部多少像素触发加载更多）
  static const double preloadThreshold = 100.0;

  // ==================== 行李状态颜色映射 ====================
  /// 行李状态 → 颜色（Material Design颜色）
  static const Map<String, Color> luggageStatusColors = {
    'checkIn':    Color(0xFF2196F3), // 蓝色
    'inTransit':  Color(0xFFFF9800), // 橙色
    'arrived':    Color(0xFF4CAF50), // 绿色
    'delivered':  Color(0xFF9C27B0), // 紫色
    'damaged':    Color(0xFFF44336), // 红色
    'lost':       Color(0xFF9E9E9E), // 灰色
  };

  /// 行李状态 → 浅色背景（用于Chip等组件）
  static const Map<String, Color> luggageStatusBgColors = {
    'checkIn':    Color(0xFFE3F2FD),
    'inTransit':  Color(0xFFFFF3E0),
    'arrived':    Color(0xFFE8F5E9),
    'delivered':  Color(0xFFF3E5F5),
    'damaged':    Color(0xFFFFEBEE),
    'lost':       Color(0xFFF5F5F5),
  };

  /// 获取行李状态的颜色
  static Color getStatusColor(String statusKey) {
    return luggageStatusColors[statusKey] ?? Colors.grey;
  }

  /// 获取行李状态的浅色背景
  static Color getStatusBgColor(String statusKey) {
    return luggageStatusBgColors[statusKey] ?? Colors.grey.shade100;
  }

  // ==================== 首页统计卡片（模拟数据） ====================
  /// 首页今日处理行李数
  static const int mockTodayProcessed = 12;

  /// 首页异常行李数
  static const int mockAbnormalLuggage = 3;

  /// 首页待办事项数
  static const int mockPendingTasks = 2;

  // ==================== 工作统计图表（模拟数据） ====================
  /// 一周标签（用于柱状图X轴）
  static const List<String> weekDayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  /// 一周处理行李数（用于柱状图）
  static const List<double> weekProcessed = [12.0, 19.0, 15.0, 17.0, 20.0, 8.0, 12.0];

  /// 一周异常行李数（用于柱状图）
  static const List<double> weekAbnormal = [2.0, 3.0, 1.0, 4.0, 2.0, 1.0, 3.0];

  // ==================== 图表颜色 ====================
  /// 已处理行李的图表颜色
  static const Color chartProcessedColor = Color(0xFF3498db);

  /// 异常行李的图表颜色
  static const Color chartAbnormalColor = Color(0xFFf39c12);
}
