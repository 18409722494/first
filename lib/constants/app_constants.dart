import 'package:flutter/material.dart';

/// 应用常量
class AppConstants {
  AppConstants._();

  // API配置
  static const String apiBaseUrl = 'http://8.137.145.195:3338';
  static const String ossUploadEndpoint = '$apiBaseUrl/upload';

  // 行李超重规则
  static const double freeBaggageWeightKg = 20.0;
  static const double overweightFeePerKg = 100.0;

  static double calculateOverweightFee(double actualWeightKg) {
    final overweight = actualWeightKg - freeBaggageWeightKg;
    return overweight > 0 ? overweight * overweightFeePerKg : 0.0;
  }

  // 分页配置
  static const int pageSize = 20;
  static const double preloadThreshold = 100.0;

  // 行李状态颜色
  static const Map<String, Color> luggageStatusColors = {
    'checkIn':    Color(0xFF2196F3),
    'inTransit':  Color(0xFFFF9800),
    'arrived':    Color(0xFF4CAF50),
    'delivered':  Color(0xFF9C27B0),
    'damaged':    Color(0xFFF44336),
    'lost':       Color(0xFF9E9E9E),
  };

  static const Map<String, Color> luggageStatusBgColors = {
    'checkIn':    Color(0xFFE3F2FD),
    'inTransit':  Color(0xFFFFF3E0),
    'arrived':    Color(0xFFE8F5E9),
    'delivered':  Color(0xFFF3E5F5),
    'damaged':    Color(0xFFFFEBEE),
    'lost':       Color(0xFFF5F5F5),
  };

  static Color getStatusColor(String statusKey) {
    return luggageStatusColors[statusKey] ?? Colors.grey;
  }

  static Color getStatusBgColor(String statusKey) {
    return luggageStatusBgColors[statusKey] ?? Colors.grey.shade100;
  }

  // 首页统计数据
  static const int mockTodayProcessed = 12;
  static const int mockAbnormalLuggage = 3;
  static const int mockPendingTasks = 2;

  // 图表数据
  static const List<String> weekDayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  static const List<double> weekProcessed = [12.0, 19.0, 15.0, 17.0, 20.0, 8.0, 12.0];
  static const List<double> weekAbnormal = [2.0, 3.0, 1.0, 4.0, 2.0, 1.0, 3.0];

  // 图表颜色
  static const Color chartProcessedColor = Color(0xFF3498db);
  static const Color chartAbnormalColor = Color(0xFFf39c12);
}
